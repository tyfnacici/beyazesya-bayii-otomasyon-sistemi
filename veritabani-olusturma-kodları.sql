create database vtbsProje_a;
use vtbsProje_a;

-- Ürünler
CREATE TABLE kategori (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kategori_adi VARCHAR(30) NOT NULL
);

CREATE TABLE markalar (
    id INT AUTO_INCREMENT PRIMARY KEY,
    marka_adi VARCHAR(20) NOT NULL
);

CREATE TABLE urunler (
    id INT AUTO_INCREMENT PRIMARY KEY,
    urun_adi VARCHAR(50) NOT NULL,
    marka_id INT,
    kategori_id INT,
    fiyat DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (kategori_id) REFERENCES kategori(id),
    FOREIGN KEY (marka_id) REFERENCES markalar(id)
);

-- magaza

CREATE TABLE magazalar (
id INT AUTO_INCREMENT PRIMARY KEY,
ad varchar(50),
adres varchar(250),
kar_oranı DECIMAL(10, 2)
);

-- Kulanıcılar

CREATE TABLE unvanlar (
id INT AUTO_INCREMENT PRIMARY KEY,
aciklama varchar(50)
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    rol INT NOT NULL DEFAULT 1, -- Admin=0, Calisan=1
    ad VARCHAR(20) NOT NULL,
    soyad VARCHAR(20) NOT NULL,
    unvan_id INT,
    maas DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (unvan_id) REFERENCES unvanlar(id)
);

CREATE TABLE musteriler (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(20) NOT NULL,
    soyad VARCHAR(20) NOT NULL
);

CREATE TABLE telefon_nolar (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tel_no VARCHAR(11)
);

CREATE TABLE adresler (
id INT AUTO_INCREMENT PRIMARY KEY,
adres varchar(250)
);

CREATE TABLE adresler_musteriler (
	musteriler_id INT,
    adresler_id INT,
    PRIMARY KEY (adresler_id, musteriler_id),
    FOREIGN KEY (adresler_id) REFERENCES adresler(id),
    FOREIGN KEY (musteriler_id) REFERENCES musteriler(id)
);

CREATE TABLE adresler_users (
	users_id INT,
    adresler_id INT,
    PRIMARY KEY (adresler_id, users_id),
    FOREIGN KEY (adresler_id) REFERENCES adresler(id),
    FOREIGN KEY (users_id) REFERENCES users(id)
);

CREATE TABLE telefon_nolar_musteriler (
	musteriler_id INT,
    telefon_nolar_id INT,
    PRIMARY KEY (telefon_nolar_id, musteriler_id),
    FOREIGN KEY (telefon_nolar_id) REFERENCES telefon_nolar(id),
    FOREIGN KEY (musteriler_id) REFERENCES musteriler(id)
);

CREATE TABLE telefon_nolar_users (
	users_id INT,
    telefon_nolar_id INT,
    PRIMARY KEY (telefon_nolar_id, users_id),
    FOREIGN KEY (telefon_nolar_id) REFERENCES telefon_nolar(id),
    FOREIGN KEY (users_id) REFERENCES users(id)
);

CREATE TABLE magazalar_users (
	users_id INT,
    magazalar_id INT,
    PRIMARY KEY (magazalar_id, users_id),
    FOREIGN KEY (magazalar_id) REFERENCES magazalar(id),
    FOREIGN KEY (users_id) REFERENCES users(id)
);
-- sıparısler

CREATE TABLE magazalar_siparis (
id INT AUTO_INCREMENT PRIMARY KEY,
siparis_tarih DATETIME DEFAULT CURRENT_TIMESTAMP,
adet INT,
magazalar_id INT,
urunler_id INT,
FOREIGN KEY (magazalar_id) REFERENCES magazalar(id),
FOREIGN KEY (urunler_id) REFERENCES urunler(id)
);

CREATE TABLE musteriler_siparis (
id INT AUTO_INCREMENT PRIMARY KEY,
siparis_tarih DATETIME DEFAULT CURRENT_TIMESTAMP,
adet INT,
musteriler_id INT,
urunler_id INT,
FOREIGN KEY (musteriler_id) REFERENCES musteriler(id),
FOREIGN KEY (urunler_id) REFERENCES urunler(id)
);

-- stok malidurum

CREATE TABLE magaza_stok (
id INT AUTO_INCREMENT PRIMARY KEY,
adet INT NOT NULL DEFAULT 0,
magazalar_id INT DEFAULT NULL,
urunler_id INT DEFAULT NULL,
FOREIGN KEY (magazalar_id) REFERENCES magazalar(id),
FOREIGN KEY (urunler_id) REFERENCES urunler(id)
);

create table magaza_mali_durum (
id INT AUTO_INCREMENT PRIMARY KEY,
gelir DECIMAL(10, 2) NOT NULL DEFAULT 0,
gider DECIMAL(10, 2) NOT NULL DEFAULT 0,
bürüt_kar DECIMAL(10, 2) NOT NULL DEFAULT 0,
magazalar_id INT,
FOREIGN KEY (magazalar_id) REFERENCES magazalar(id)
);

-- View

CREATE VIEW magaza_stok_durum AS
SELECT 
 magazalar.ad AS magaza_adi,
 urunler.urun_adi,
 urunler.fiyat,
 magaza_stok.adet,
 'Stokta' AS stok_durumu
FROM magaza_stok
JOIN magazalar ON magazalar.id = magaza_stok.magazalar_id
JOIN urunler ON urunler.id = magaza_stok.urunler_id
WHERE
    magaza_stok.adet > 0

UNION

SELECT 
 magazalar.ad AS magaza_adi,
 urunler.urun_adi,
 urunler.fiyat,
 magaza_stok.adet,
 'Stokta Yok' AS stok_durumu
FROM magaza_stok
JOIN magazalar ON magazalar.id = magaza_stok.magazalar_id
JOIN urunler ON urunler.id = magaza_stok.urunler_id
WHERE
    magaza_stok.adet = 0

UNION

SELECT
    magazalar.ad AS magaza_adi,
    urunler.urun_adi,
    urunler.fiyat,
    magaza_stok.adet,
    'Stok Ekside' AS stok_durumu
FROM magaza_stok
JOIN magazalar ON magazalar.id = magaza_stok.magazalar_id
JOIN urunler ON urunler.id = magaza_stok.urunler_id
WHERE
    magaza_stok.adet < 0;


CREATE VIEW siparisler AS
SELECT 
 magazalar.ad AS magaza_adi,
 urunler.urun_adi,
 urunler.fiyat,
 magazalar_siparis.adet, 
 magazalar_siparis.siparis_tarih, 
 'magaza' AS siparis_turu
FROM magazalar_siparis
JOIN magazalar ON magazalar.id = magazalar_siparis.magazalar_id
JOIN urunler ON urunler.id = magazalar_siparis.urunler_id

UNION

SELECT musteriler.ad AS 
 musteri_adi, 
 urunler.urun_adi, 
 urunler.fiyat,
 musteriler_siparis.adet,
 musteriler_siparis.siparis_tarih,
 'musteri' AS siparis_turu
FROM musteriler_siparis
JOIN musteriler ON musteriler.id = musteriler_siparis.musteriler_id
JOIN urunler ON urunler.id = musteriler_siparis.urunler_id;

-- Trigger

show triggers;
DELIMITER $$
CREATE TRIGGER tr_magazalar AFTER INSERT ON magazalar
FOR EACH ROW
BEGIN
    INSERT INTO magaza_mali_durum (magazalar_id) VALUES (NEW.id);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tr_magazalar_stok AFTER INSERT ON magazalar_siparis
FOR EACH ROW
BEGIN
    IF
    (SELECT COUNT(*) FROM magaza_stok WHERE magazalar_id = NEW.magazalar_id AND urunler_id = NEW.urunler_id) > 0
    THEN
        UPDATE magaza_stok SET adet = adet + NEW.adet WHERE magazalar_id = NEW.magazalar_id AND urunler_id = NEW.urunler_id;
    ELSE
        INSERT INTO magaza_stok (magazalar_id, urunler_id, adet) VALUES (NEW.magazalar_id, NEW.urunler_id, NEW.adet);
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tr_musteriler_stok AFTER INSERT ON musteriler_siparis
FOR EACH ROW
BEGIN
    IF
    (SELECT COUNT(*) FROM magaza_stok WHERE magazalar_id = (SELECT magazalar_id FROM musteriler WHERE id = NEW.musteriler_id) AND urunler_id = NEW.urunler_id) > 0
    THEN
        UPDATE magaza_stok SET adet = adet - NEW.adet WHERE magazalar_id = (SELECT magazalar_id FROM musteriler WHERE id = NEW.musteriler_id) AND urunler_id = NEW.urunler_id;
    ELSE
        INSERT INTO magaza_stok (magazalar_id, urunler_id, adet) VALUES ((SELECT magazalar_id FROM musteriler WHERE id = NEW.musteriler_id), NEW.urunler_id, NEW.adet);
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tr_magazalar_mali_durum AFTER INSERT ON magazalar_siparis
FOR EACH ROW
BEGIN
    UPDATE 
    magaza_mali_durum 
    SET 
    gider = gider + (NEW.adet * (SELECT fiyat FROM urunler WHERE id = NEW.urunler_id)),
    gelir = gelir + (NEW.adet * (SELECT fiyat FROM urunler WHERE id = NEW.urunler_id) * ((SELECT kar_oranı FROM magazalar WHERE id = NEW.magazalar_id) + 1)),
    bürüt_kar = gelir - gider
    WHERE 
    magazalar_id = NEW.magazalar_id;
END$$
DELIMITER ;
show triggers;
-- Indexler
CREATE INDEX idx_musteriler_id ON musteriler (id);
CREATE INDEX idx_adresler_id ON adresler (id);
CREATE INDEX idx_telefon_nolar_id ON telefon_nolar (id);
CREATE INDEX idx_magazalar_id ON magazalar (id);
CREATE INDEX idx_magaza_stok_id ON magaza_stok (id);

-- ÖRNEK VERİLER


-- Magaza verileri girişleri
INSERT INTO magazalar (ad, adres, kar_oranı) VALUES ('Alinin Beyaz Eşyaları', 'İstanbul, Beşiktaş', 0.30);
INSERT INTO magazalar (ad, adres, kar_oranı) VALUES ('Al Götür Hemen Ev Eşyaları', 'Ankara, Kızılay', 0.20);
INSERT INTO magazalar (ad, adres, kar_oranı) VALUES ('En İyi Ev Eşyaları Mağazası', 'İzmir, Karşıyaka', 0.25);
INSERT INTO magazalar (ad, adres, kar_oranı) VALUES  ('Mağazaların En İyisi', 'Ankara, Keçiören', 0.15);

-- Ürünler veri girişleri
INSERT INTO kategori (kategori_adi) VALUES ('Buzdolabı');
INSERT INTO kategori (kategori_adi) VALUES ('Çamaşır Makinesi');
INSERT INTO kategori (kategori_adi) VALUES ('Televizyon');
INSERT INTO kategori (kategori_adi) VALUES ('Bulaşık Makinesi');
INSERT INTO kategori (kategori_adi) VALUES ('Fırın');

INSERT INTO markalar (marka_adi) VALUES ('Vestel');
INSERT INTO markalar (marka_adi) VALUES ('SEG');
INSERT INTO markalar (marka_adi) VALUES ('Regal');
INSERT INTO markalar (marka_adi) VALUES ('FINLUX');

INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("RETRO FD56001 BORDO", 1, 1, 28872);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("PUZZLE FD65001 EX VAKUM", 1, 1, 47538);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK72012 EX GI Pro Wi-Fi", 1, 1, 31181);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK54001 CRS GI Pro", 1, 1, 29979);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK52102 ES Wi-Fi", 1, 1, 20124);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK37101", 2, 1, 13599);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK48001", 2, 1, 15563);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK52001", 2, 1, 16920);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NF60011 CRB GI Pro ", 2, 1, 30627);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK 64031 E Y 588 Lt No-Frost", 3, 1, 21899);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK 54020 SC 487 Lt No-Frost", 3, 1, 24999);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("NFK 72010 EX 650 Lt No-Frost", 3, 1, 26499);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ("FD 65001 EX 588 Lt No-Frost", 3, 1, 30499);

INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel V-1200 Çamaşır Makinesi', 1, 2, 3500);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG S-800 Çamaşır Makinesi', 2, 2, 3200);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal R-1000 Çamaşır Makinesi', 3, 2, 3700);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('FINLUX F-900 Çamaşır Makinesi', 4, 2, 3800);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel V-1300 Çamaşır Makinesi', 1, 2, 3700);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG S-850 Çamaşır Makinesi', 2, 2, 3300);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal R-1100 Çamaşır Makinesi', 3, 2, 3600);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('FINLUX F-950 Çamaşır Makinesi', 4, 2, 3900);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel V-1400 Çamaşır Makinesi', 1, 2, 4000);

INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel 43FA7100 43" Full HD LED Televizyon', 1, 3, 4500);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG 40HD7100 40" HD LED Televizyon', 2, 3, 3100);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal 55U8200 55" 4K Ultra HD LED Televizyon', 3, 3, 5700);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('FINLUX 65FX8100 65" 4K Ultra HD LED Televizyon', 4, 3, 7000);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel 49FA7100 49" Full HD LED Televizyon', 1, 3, 4800);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel 40FA7100 40" Full HD LED Televizyon', 1, 3, 4200);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG 32HD7100 32" HD LED Televizyon', 2, 3, 2900);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal 50U8200 50" 4K Ultra HD LED Televizyon', 3, 3, 5200);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('FINLUX 55FX8100 55" 4K Ultra HD LED Televizyon', 4, 3, 6000);

INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel D-8200 Bulaşık Makinesi', 1, 4, 2500);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG S-6100 Bulaşık Makinesi', 2, 4, 2300);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal R-7100 Bulaşık Makinesi', 3, 4, 2700);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('FINLUX F-7900 Bulaşık Makinesi', 4, 4, 2800);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel D-8500 Bulaşık Makinesi', 1, 4, 2600);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG S-6200 Bulaşık Makinesi', 2, 4, 2400);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal R-7200 Bulaşık Makinesi', 3, 4, 2900);

INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel VEO-6700 Multifonksiyonel Fırın', 1, 5, 2100);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG S-4600 Ankastre Fırın', 2, 5, 1900);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal R-6000 Ankastre Fırın', 3, 5, 2200);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('FINLUX F-4000 Ankastre Fırın', 4, 5, 2300);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel VEO-6800 Multifonksiyonel Fırın', 1, 5, 2400);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG S-4700 Ankastre Fırın', 2, 5, 2000);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Regal R-6100 Ankastre Fırın', 3,5, 2400);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('FINLUX F-4100 Ankastre Fırın', 4, 5, 2500);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('Vestel VEO-6900 Multifonksiyonel Fırın', 1, 5, 2600);
INSERT INTO urunler (urun_adi, marka_id, kategori_id, fiyat) VALUES ('SEG S-4800 Ankastre Fırın', 2, 5, 2100);


-- Müşteriler
INSERT INTO musteriler (ad, soyad) VALUES ('Ayşe', 'Kara');
INSERT INTO musteriler (ad, soyad) VALUES ('Ali', 'Demir');
INSERT INTO musteriler (ad, soyad) VALUES ('Ahmet', 'Yılmaz');
INSERT INTO musteriler (ad, soyad) VALUES ('Mehmet', 'Demir');
INSERT INTO musteriler (ad, soyad) VALUES ('Fatma', 'Aydın');
INSERT INTO musteriler (ad, soyad) VALUES ('Ali', 'Yılmaz');
INSERT INTO musteriler (ad, soyad) VALUES ('Mehmet', 'Öztürk');
INSERT INTO musteriler (ad, soyad) VALUES ('Elif', 'Kara');
INSERT INTO musteriler (ad, soyad) VALUES ('Fatma', 'Demir');
INSERT INTO musteriler (ad, soyad) VALUES ('Ahmet', 'Acar');
INSERT INTO musteriler (ad, soyad) VALUES ('Esra', 'Can');
INSERT INTO musteriler (ad, soyad) VALUES ('Murat', 'Koç');
INSERT INTO musteriler (ad, soyad) VALUES ('Şeyma', 'Yıldız');
INSERT INTO musteriler (ad, soyad) VALUES ('Hasan', 'Kılıç');
INSERT INTO musteriler (ad, soyad) VALUES ('Gizem', 'Bulut');
INSERT INTO musteriler (ad, soyad) VALUES ('İbrahim', 'Yıldırım');
INSERT INTO musteriler (ad, soyad) VALUES ('Ceren', 'Kaplan');
INSERT INTO musteriler (ad, soyad) VALUES ('Kerem', 'Doğan');
INSERT INTO musteriler (ad, soyad) VALUES ('Aslı', 'Arslan');
INSERT INTO musteriler (ad, soyad) VALUES ('Fırat', 'Uysal');

-- Unvanlar verileri ekleme
INSERT INTO unvanlar (aciklama) VALUES ('System');
INSERT INTO unvanlar (aciklama) VALUES ('Müdür');
INSERT INTO unvanlar (aciklama) VALUES ('Satış Temsilcisi');
INSERT INTO unvanlar (aciklama) VALUES ('Kasiyer');


-- Kullanıcılar
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('admin', '123456', 0, 'Admin', 'Kullanıcı', 1, 0);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('ahmetyilmaz', '1234q2312312356', 1, 'Ahmet', 'Yılmaz', 2, 7500.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('mehmetkaya', 'abcdeeq23qwe24f', 1, 'Mehmet', 'Kaya', 3, 4500.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('aysehambıllıoğlu', 'arwerybcwew', 1, 'Ayşe', 'Hambıllıoğlu', 4, 13500.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('aliyildiz', 'saf42dfg34sfd456r', 1, 'Ali', 'Yıldız', 2, 5000.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('ozgedemir', 'fg43dfrt54fdg45t', 1, 'Özge', 'Demir', 3, 6000.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('ayseozkan', 'g54gdf54gfd54fgf', 1, 'Ayşe', 'Özkan', 4, 6500.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('cemkaya', 'gf45fd4g4d4g4df4', 1, 'Cem', 'Kaya', 2, 4400.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('fatosaglam', 'gh5fg5d45f5g5df5', 1, 'Fatoş', 'Ağlam', 3, 5500.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('metincakir', 'j56jh6g5hj5h6jh5', 1, 'Metin', 'Çakır', 4, 7000.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('sevgikilic', 'fdg56fd4gdfg45fg', 1, 'Sevgi', 'Kılıç', 2, 4800.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('hakanaktas', 'gfh56gfh5gf5hgfh', 1, 'Hakan', 'Aktaş', 3, 5200.00);
INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES ('aylindogan', 'gfh5gf5gh5gf5gh5', 1, 'Aylin', 'Doğan', 4, 7500.00);

-- Telefon numaraları ekleme
INSERT INTO telefon_nolar (tel_no) VALUES ('05001234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('05321234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('05551234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('05431234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('5551234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('5324567890');
INSERT INTO telefon_nolar (tel_no) VALUES ('2125551234');
INSERT INTO telefon_nolar (tel_no) VALUES ('2125554321');
INSERT INTO telefon_nolar (tel_no) VALUES ('5559876543');
INSERT INTO telefon_nolar (tel_no) VALUES ('05551234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('05321234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('05441234567');
INSERT INTO telefon_nolar (tel_no) VALUES ('05327654321');
INSERT INTO telefon_nolar (tel_no) VALUES ('05543321567');
INSERT INTO telefon_nolar (tel_no) VALUES ('05433457890');
INSERT INTO telefon_nolar (tel_no) VALUES ('05368889090');
INSERT INTO telefon_nolar (tel_no) VALUES ('05324561234');
INSERT INTO telefon_nolar (tel_no) VALUES ('05421111111');
INSERT INTO telefon_nolar (tel_no) VALUES ('05554443322');
INSERT INTO telefon_nolar (tel_no) VALUES ('05333222444');
INSERT INTO telefon_nolar (tel_no) VALUES ('05335557777');
INSERT INTO telefon_nolar (tel_no) VALUES ('05457777777');
INSERT INTO telefon_nolar (tel_no) VALUES ('05553338899');
INSERT INTO telefon_nolar (tel_no) VALUES ('05329995511');
INSERT INTO telefon_nolar (tel_no) VALUES ('05444444444');
INSERT INTO telefon_nolar (tel_no) VALUES ('05352225588');
INSERT INTO telefon_nolar (tel_no) VALUES ('05347772266');
INSERT INTO telefon_nolar (tel_no) VALUES ('05556667788');
INSERT INTO telefon_nolar (tel_no) VALUES ('05465554455');
INSERT INTO telefon_nolar (tel_no) VALUES ('05344445566');
INSERT INTO telefon_nolar (tel_no) VALUES ('05333338899');
INSERT INTO telefon_nolar (tel_no) VALUES ('05551111222');

-- Adresler verileri ekleme
INSERT INTO adresler (adres) VALUES ('İstiklal Caddesi No:12 Daire:5 Beyoğlu İstanbul');
INSERT INTO adresler (adres) VALUES ('Atatürk Mahallesi 1521. Sk. No: 12/4 Çankaya Ankara');
INSERT INTO adresler (adres) VALUES ('İnönü Mahallesi Cumhuriyet Cd. No:45/A Esenyurt İstanbul');
INSERT INTO adresler (adres) VALUES ('Çamlık Mahallesi 3202 Sokak No:3/A Bayraklı İzmir');
INSERT INTO adresler (adres) VALUES ('Söğütlüçeşme Caddesi No:15/3 Kadıköy İstanbul');
INSERT INTO adresler (adres) VALUES ('Uludağ Üniversitesi Görükle Kampüsü Nilüfer Bursa');
INSERT INTO adresler (adres) VALUES ('Mevlana Mah. İzmir Cd. No:21/1 Karabağlar İzmir');
INSERT INTO adresler (adres) VALUES ('Bahçeşehir Mahallesi Dereboyu Cd. No:56/B Başakşehir İstanbul');
INSERT INTO adresler (adres) VALUES ('Mithatpaşa Mah. Hacıhasan Sk. No:10/A Çankaya Ankara');
INSERT INTO adresler (adres) VALUES ('Kazasker Mahallesi, Şehit Muhtar Bey Cd. No: 67/1 Kadıköy İstanbul');
INSERT INTO adresler (adres) VALUES ('Adnan Kahveci Mah. Kordon Cd. No:12/4 Beşiktaş İstanbul');
INSERT INTO adresler (adres) VALUES ('Mustafa Kemal Paşa Mah. Atatürk Bulvarı No:34 Nilüfer Bursa');
INSERT INTO adresler (adres) VALUES ('Fatih Mahallesi, Huzur Caddesi, 34794 Ataşehir/İstanbul');
INSERT INTO adresler (adres) VALUES ('Yalı Mahallesi, Demet Sk. No:16, 16450 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Tuna Mahallesi, Fulya Cd. No:6, 16170 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Çakmak Mahallesi, 2013. Sk. No:17, 16090 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Abdurrahmangazi Mahallesi, 1042. Sk. No:23, 16250 Osmangazi/Bursa');
INSERT INTO adresler (adres) VALUES ('Esenler Mahallesi, Zeytinlik Cd. No:44, 16370 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Bahar Mahallesi, Mithatpaşa Cd. No:32, 16040 Osmangazi/Bursa');
INSERT INTO adresler (adres) VALUES ('Sırameşeler Mahallesi, Bursa Cd. No:53, 16010 Osmangazi/Bursa');
INSERT INTO adresler (adres) VALUES ('Merkez Mahallesi, 10. Sk. No:34, 16370 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Fethiye Mahallesi, Lefkoşa Cd. No:24, 16500 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Kayabaşı Mahallesi, Kayabaşı Cd. No:17, 16140 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Bahçelievler Mahallesi, 1. Cd. No:8, 16370 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Kurtuluş Mahallesi, Kurtuluş Cd. No:35, 16220 Osmangazi/Bursa');
INSERT INTO adresler (adres) VALUES ('Üçevler Mahallesi, Cerrahpaşa Cd. No:46, 16210 Osmangazi/Bursa');
INSERT INTO adresler (adres) VALUES ('Kestel Mahallesi, Fevzi Çakmak Cd. No:58, 16130 Kestel/Bursa');
INSERT INTO adresler (adres) VALUES ('Çamlıca Mahallesi, Kavak Sk. No:25, 16450 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Hasanağa Mahallesi, 2. Cd. No:18, 16450 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Kültür Mahallesi, Zafer Cd. No:12, 16210 Osmangazi/Bursa');
INSERT INTO adresler (adres) VALUES ('Görükle Mahallesi, Küçüksu Cd. No:14, 16370 Nilüfer/Bursa');
INSERT INTO adresler (adres) VALUES ('Barış Mahallesi, Ova Sk. No:39, 16370 Nilüfer/Bursa');

-- Müşteri adresleri ekleme
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (1, 13);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (2, 14);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (3, 15);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (4, 16);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (5, 17);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (6, 18);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (7, 19);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (8, 20);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (9, 21);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (10, 22);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (11, 23);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (12, 24);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (13, 25);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (14, 26);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (15, 27);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (16, 28);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (17, 29);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (18, 30);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (19, 31);
INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (20, 32);

-- Kullanıcı adresleri ekleme
INSERT INTO adresler_users (users_id, adresler_id) VALUES (1, 1);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (2, 2);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (3, 3);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (4, 4);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (5, 5);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (6, 6);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (7, 7);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (8, 8);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (9, 9);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (10, 10);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (11, 11);
INSERT INTO adresler_users (users_id, adresler_id) VALUES (12, 12);

-- Müşteri telefon numaraları ekleme
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (1, 13); 
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (2, 14);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (3, 15);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (4, 16);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (5, 17);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (6, 18);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (7, 19);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (8, 20);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (9, 21);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (10, 22);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (11, 23);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (12, 24);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (13, 25);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (14, 26);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (15, 27);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (16, 28);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (17, 29);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (18, 30);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (19, 31);
INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (20, 32);

-- Kullanıcı telefon numaraları ekleme
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (1, 1);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (2, 2);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (3, 3);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (4, 4);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (5, 5);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (6, 6);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (7, 7);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (8, 8);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (9, 9);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (10, 10);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (11, 11);
INSERT INTO telefon_nolar_users (users_id, telefon_nolar_id) VALUES (12, 12);

-- Kulanıcı Magaza Eşleme
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (2, 1);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (3, 1);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (4, 1);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (5, 2);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (6, 2);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (7, 2);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (8, 3);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (9, 3);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (10, 3);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (11, 4);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (12, 4);
INSERT INTO magazalar_users (users_id, magazalar_id) VALUES (13, 4);

-- Bayi Siparişleri
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 1, 2);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 2, 7);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 13);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 18);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 22);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 4, 29);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 35);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 41);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 47);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 3, 48);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 5);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 12);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 17);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 20);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 24);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 3, 30);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 34);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 40);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 46);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 48);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 3);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 10);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 14);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 19);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 21);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 4, 27);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 33);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 32);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 45);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 45);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 1);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 8);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 11);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 16);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 23);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 1, 28);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 36);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 43);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 48);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 5);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 6);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 13);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 15);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 21);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 25);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 2, 31);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 38);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 42);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 46);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 23);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 4);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 11);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 14);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 18);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 22);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 2, 26);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 32);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 31);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 47);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 41);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 2);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 9);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 12);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 17);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 20);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 3, 28);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 34);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 40);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 45);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 8);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 7);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 14);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 16);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 19);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 23);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 2, 30);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 35);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 41);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 47);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 32);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 5);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 12);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 17);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 20);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 24);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 2, 29);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 33);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 42);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 48);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 20);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 3);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 10);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 13);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 16);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 21);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 1, 26);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 34);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 39);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 45);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 48);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 1);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 8);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 11);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 19);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 23);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (2, 1, 27);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (4, 2, 38);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (6, 3, 40);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (8, 1, 46);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (9, 4, 20);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (5, 2, 6);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (3, 1, 13);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (10, 4, 15);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (1, 3, 17);
INSERT INTO magazalar_siparis (adet, magazalar_id, urunler_id) VALUES (7, 1, 25);

-- Müşterileri siaprişleri

INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 5, 23);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 14, 9);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 1, 43);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 8, 18);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 20, 23);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 16, 3);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 3, 39);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 7, 11);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 11, 28);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 2, 46);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 17, 7);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 4, 30);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 13, 35);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 10, 42);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 15, 21);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 6, 14);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 18, 40);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 9, 25);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 12, 42);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 19, 6);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 1, 16);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 5, 33);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 14, 22);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 1, 44);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 8, 2);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 20, 26);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 16, 13);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 3, 36);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 7, 29);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 11, 5);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 2, 42);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 17, 20);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 4, 37);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 13, 11);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 10, 8);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 15, 15);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 6, 27);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 18, 34); 
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 9, 12); 
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 12, 10);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 19, 41);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 1, 19);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 5, 7);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 14, 30);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 1, 2);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 8, 42);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 20, 16);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 16, 35);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 3, 21);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 7, 43);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 11, 6);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 2, 17);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 17, 11);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 4, 28);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 13, 47);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 10, 30);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 15, 38);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 6, 27);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 18, 9);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 9, 4);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 12, 32);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 19, 1);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 1, 12);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 5, 23);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 14, 45);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 1, 38);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 8, 31);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 20, 25);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 16, 6);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 3, 47);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 7, 20);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 11, 44);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 2, 37);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 17, 8);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 4, 14);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 13, 2);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 10, 15);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 15, 18);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 6, 27);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 18, 24);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 9, 30);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 12, 7);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 19, 5);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 1, 31);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 5, 38);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 14, 29);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 1, 22);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 8, 10);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 20, 19);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 16, 46);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 3, 41);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 7, 3);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 11, 33);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 2, 29);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 17, 16);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 4, 26);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 13, 13);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (3, 10, 45);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 15, 42); 
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 6, 47);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 18, 48);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 9, 39);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 12, 20);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 19, 39);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 1, 7);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 5, 30);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 14, 11);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 1, 5);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 8, 36);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 20, 42);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 16, 17);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 3, 25);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 7, 8);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 11, 14);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 2, 46);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 17, 1);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 4, 33);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 13, 31);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 10, 23);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 15, 19);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 6, 30);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 18, 11);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 9, 48);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 12, 43);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 19, 27);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 1, 2);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (2, 5, 47);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES  (1, 14, 39);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 1, 10);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 8, 22);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 20, 31);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 16, 38);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 3, 20);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES(2, 7, 14);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 11, 26);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 2, 8);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 17, 41);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 4, 45);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES(1, 13, 41);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 10, 28);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 15, 5);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 6, 16);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 18, 32);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 9, 15); 
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 12, 9);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 19, 18);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 1, 36);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 5, 1);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 14, 4);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 1, 26);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 8, 17);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 20, 47);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 16, 42);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 3, 34);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 7, 25);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 11, 15);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 2, 13);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 17, 38);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 4, 21);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 13, 10);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (3, 10, 37);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (2, 15, 28);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1, 6, 41);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES(2, 18, 46);
INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (1,5,32); 
