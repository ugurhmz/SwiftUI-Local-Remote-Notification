#  Native Node.js APNs Pusher (HTTP/2 & Resumable)

Bu proje, Firebase veya OneSignal gibi 3. parti servisler **kullanmadan**, doğrudan **Apple Push Notification Service (APNs)** ile **HTTP/2** protokolü üzerinden haberleşen, saf bir Node.js projesidir.

Amaç; APNs altyapısını, **JWT (JSON Web Token)** tabanlı kimlik doğrulamayı, mantığını native düzeyde simüle etmektir.

## Nodejs Örnek Kodumuz. Gerekli yerleri kendi bilgileriniz ile doldurun.

```javascript
const fs = require('fs');
const http2 = require('http2');
const jwt = require('jsonwebtoken');
const path = require('path');

// ==================================================================
// ▼▼▼ 1. AYARLAR (SADECE BU ARALIĞI DOLDURMAN YETERLİ) ▼▼▼
// ==================================================================

const AYARLAR = {
    // Apple Developer'dan alınan 10 haneli Key ID
    KEY_ID: "ABC1...... örnek, sen seninkiyle doldur.", 

    // Apple Developer'da isminin yanında yazan Team ID
    TEAM_ID: "XYZ9...... örnek, sen seninkiyle doldur.",

    // Uygulamanın Bundle ID'si (Xcode'da yazan)
    BUNDLE_ID: "com.rico.SwiftUINotifiApp",

    // .p8 dosyasının bilgisayarındaki TAM yolu
    // (Dosyayı terminale sürükleyip yolu kopyalayabilirsin)
    P8_DOSYA_YOLU: "/Users/kullanici/Desktop/AuthKey_xxxx.p8",

    // GÖNDERİLECEK MESAJ İÇERİĞİ
    MESAJ_BASLIK: "Selam! 👋",
    MESAJ_ICERIK: "Bu bildirim Node.js ile gönderildi.",

    // Test yaparken: false | Uygulamayı yayınlayınca: true
    PRODUCTION_MODU: false, 

    // BİLDİRİM GÖNDERİLECEK CİHAZ LİSTESİ (Token'ları buraya ekle) XCODE > Console'dakı TOKEN
    HEDEF_LISTESI: [
        "74d823... (birinci cihaz tokeni)",
        "82a91b... (ikinci cihaz tokeni)",
        // Virgül koyarak alta yeni satır ekleyebilirsin
    ]
};

// ==================================================================
// ▲▲▲ AYARLAR BİTTİ - BURADAN AŞAĞISINA DOKUNMANA GEREK YOK ▲▲▲
// ==================================================================

const APNS_HOST = AYARLAR.PRODUCTION_MODU ? 'api.push.apple.com' : 'api.sandbox.push.apple.com';
const STATE_FILE = path.join(__dirname, 'durum.json'); // Kaldığımız yeri tutan dosya

// 1. JWT Token Oluşturma (Kimlik Doğrulama)
function getJwtToken() {
    try {
        const privateKey = fs.readFileSync(AYARLAR.P8_DOSYA_YOLU);
        return jwt.sign(
            { iss: AYARLAR.TEAM_ID, iat: Math.floor(Date.now() / 1000) },
            privateKey,
            { algorithm: 'ES256', header: { alg: 'ES256', kid: AYARLAR.KEY_ID } }
        );
    } catch (e) {
        console.error("\n❌ KRİTİK HATA: .p8 dosyası bulunamadı!");
        console.error("Lütfen 'P8_DOSYA_YOLU' kısmını kontrol et.\n");
        console.error("Hata Detayı:", e.message);
        process.exit(1);
    }
}

// 2. Durumu Okuma (En son nerede kaldık?)
function getLastState() {
    if (fs.existsSync(STATE_FILE)) {
        return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
    }
    return { lastIndex: -1 }; // Dosya yoksa -1 (hiç başlanmamış)
}

// 3. Durumu Kaydetme (Şu an buradayız)
function saveState(index) {
    fs.writeFileSync(STATE_FILE, JSON.stringify({ lastIndex: index }));
}

// 4. Tekil Bildirim Gönderme İşlemi
function sendPush(client, deviceToken) {
    return new Promise((resolve) => {
        const token = getJwtToken();
        
        const req = client.request({
            ':method': 'POST',
            ':path': `/3/device/${deviceToken}`,
            'authorization': `bearer ${token}`,
            'apns-topic': AYARLAR.BUNDLE_ID,
            'apns-push-type': 'alert',
            'apns-priority': '10'
        });

        const payload = JSON.stringify({
            "aps": {
                "alert": {
                    "title": AYARLAR.MESAJ_BASLIK,
                    "body": AYARLAR.MESAJ_ICERIK
                },
                "sound": "default",
                "badge": 1
            }
        });

        req.on('response', (headers) => {
            const status = headers[':status'];
            const apnsId = headers['apns-id'] || 'Bilinmiyor';
            
            if (status === 200) {
                console.log(`✅ BAŞARILI [${status}]: ...${deviceToken.slice(-6)}`);
            } else {
                console.log(`⚠️ HATA [${status}]: ...${deviceToken.slice(-6)}`);
            }
            
            // Başarılı da olsa hatalı da olsa işlem döngüsünü kırmamak için resolve ediyoruz
            resolve();
        });

        req.on('error', (err) => {
            console.error(`💥 BAĞLANTI HATASI: ...${deviceToken.slice(-6)}`, err);
            resolve(); // Hata olsa bile diğerine geç
        });

        req.write(payload);
        req.end();
    });
}

// 5. Ana Çalıştırma Fonksiyonu
async function main() {
    console.clear();
    console.log("🤖 Bildirim Botu Başlatılıyor...\n");

    // Apple sunucusuna bağlan
    const client = http2.connect(`https://${APNS_HOST}`);
    client.on('error', (err) => console.error('Sunucu Bağlantı Hatası:', err));

    // Kaldığımız yeri kontrol et
    const state = getLastState();
    let startIndex = state.lastIndex + 1;
    const toplamHedef = AYARLAR.HEDEF_LISTESI.length;

    if (startIndex >= toplamHedef) {
        console.log("🏁 Liste zaten tamamlanmış! Yeniden başlamak için 'durum.json' dosyasını silin.");
        client.close();
        return;
    }

    if (startIndex > 0) {
        console.log(`🔄 KAYIT BULUNDU: ${startIndex + 1}. sıradan devam ediliyor...`);
        console.log(`📊 Kalan: ${toplamHedef - startIndex} kişi\n`);
    } else {
        console.log(`▶️ SIFIRDAN BAŞLANIYOR... Toplam: ${toplamHedef} kişi\n`);
    }

    // Döngüyü başlat
    for (let i = startIndex; i < toplamHedef; i++) {
        const token = AYARLAR.HEDEF_LISTESI[i];
        
        // Kullanıcıya bilgi ver (Örn: "İşleniyor 1/100")
        process.stdout.write(`⏳ (${i + 1}/${toplamHedef}) Gönderiliyor... `);

        // Gönderimi yap
        await sendPush(client, token);
        
        // Bu adımı bitirdiğimiz için KAYDET
        saveState(i);

        // Apple'ı spamlamamak için çok kısa bekleme (100ms)
        await new Promise(r => setTimeout(r, 100));
    }

    console.log("\n🏁 TÜM LİSTE TAMAMLANDI.");
    client.close();
    
    // İstersen işlem bitince kayıt dosyasını silebilirsin: Böylece tekrar tekrar bildirim gönderebilirsin.
     fs.unlinkSync(STATE_FILE); 
}

main();
```
