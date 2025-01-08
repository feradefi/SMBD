CREATE DATABASE rental_mobil_abc;
USE rental_mobil_abc;

CREATE TABLE users(
    id_users INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    username VARCHAR (30) NOT NULL,
	no_telepon VARCHAR (15)NOT NULL,
	email VARCHAR (50) NOT NULL,
    password VARCHAR (225) NOT NULL,
    role ENUM ('Admin','User') NOT NULL,
    alamat VARCHAR (100) NOT NULL,
    gambar VARCHAR(225) NOT NULL
);
INSERT INTO users ( username, no_telepon, email, password, role, alamat, gambar) 
VALUES 
('intan', 08656789, 'intan1@gmail.com', 'admin123', 'Admin', 'Jl. Raya No. 123', 'intan.jpg'),
( 'salsa',4567890, 'salsa00@gmail.com', 'salsa99', 'User', 'Jl. Mawar No. 456', 'salsa.jpg'),
( 'risa',67890987, 'risa123@gmail.com', 'risa123', 'User', 'Jl. Angrek No. 20', 'risa.jpg');

CREATE TABLE mobil (
	id_mobil INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	merk VARCHAR (50) NOT NULL,
	model VARCHAR (50) NOT NULL,
	tahun INT (11) NOT NULL,
	warna VARCHAR (20) NOT NULL,
	harga_perhari int(11) NOT NULL,
	status ENUM ('Dipinjam','Tersedia', 'Perbaikan') NOT NULL,
	gambar VARCHAR (225) NOT NULL
);
INSERT INTO mobil (merk, model, tahun, warna, harga_perhari, status, gambar) VALUES
('Toyota', 'Avanza', 2020, 'Putih', 500000, 'Tersedia', 'toyota.jpg'),
('Hyundai', 'Santa Fe', 2018, 'Hitam', 950000, 'Dipinjam', 'hyundai.jpg'),
('Ford', 'Everest', 2019, 'Hitam', 900000, 'Perbaikan', 'ford.jpg');

CREATE TABLE perawatan (
	id_perawatan INT (11) PRIMARY KEY AUTO_INCREMENT NOT NULL,
	id_mobil INT (11)NOT NULL ,
	tanggal DATE NOT NULL,
	deskripsi TEXT NOT NULL ,
	biaya int(11) NOT NULL,
	status ENUM ('Belum Selesai','Selesai') NOT NULL,
	FOREIGN KEY (id_mobil)REFERENCES mobil(id_mobil)
);
INSERT INTO perawatan (id_mobil, tanggal, deskripsi, biaya, status) VALUES
(1, '2024-01-15', 'Penggantian oli mesin', 300000, 'Selesai'),
(2, '2023-02-10', 'Penggantian kampas rem', 250000, 'Selesai'),
(3, '2023-03-05', 'Servis rutin', 450000, 'Belum Selesai');

CREATE TABLE transaksi (
    id_transaksi INT (11) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    id_users INT (11) NOT NULL,
    id_mobil INT (11) NOT NULL,    
    tanggal_mulai DATE NOT NULL,
    tanggal_Selesai DATE NOT NULL,
    total_biaya int (11) NOT NULL,
    status_transaksi ENUM ('Belum Selesai','Selesai') NOT NULL,
    FOREIGN KEY (id_users) REFERENCES users(id_users),
    FOREIGN KEY (id_mobil) REFERENCES mobil(id_mobil)
);

INSERT INTO transaksi (id_users, id_mobil, tanggal_mulai, tanggal_Selesai, total_biaya, status_transaksi) VALUES
(2, 1, '2024-05-01', '2024-05-03', 1500000, 'Selesai'), -- Avanza, 3 hari
(3, 2, '2024-05-09', '2024-05-10', 950000, 'Selesai'), -- Santa Fe, 1 hari
(2, 3, '2024-05-05', '2024-05-09', 3200000, 'Selesai');

CREATE TABLE pembayaran(
    id_pembayaran INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    id_transaksi INT (11) NOT NULL,
    metode_pembayaran ENUM('BRI','BNI','BTN','MANDIRI','DANA','CASH') NOT NULL,
    tanggal_pembayaran DATE NOT NULL,
    jumlah_pembayaran INT (11) NOT NULL,
    status ENUM ('LUNAS','BELUM LUNAS') NOT NULL,  
    denda INT (11) NOT NULL,
    FOREIGN KEY (id_transaksi) REFERENCES transaksi (id_transaksi)
);
INSERT INTO pembayaran (id_transaksi, metode_pembayaran, tanggal_pembayaran, jumlah_pembayaran, status, denda) 
VALUES 
(1, 'BRI', '2024-05-03', 1500000, 'LUNAS', 0),
(2, 'CASH', '2024-05-10', 950000, 'LUNAS', 50000),
(3, 'BNI', '2024-05-10', 950000, 'LUNAS', 0);


-- ===============VIEW======================
-- 1. View Mobil yang Sedang Dipinjam:
CREATE VIEW mobil_dipinjam_view AS
SELECT
    m.id_mobil,
    m.merk,
    m.model,
    m.tahun,
    m.warna,
    t.tanggal_mulai,
    t.tanggal_Selesai,
    u.username AS nama_pelanggan
FROM mobil m
INNER JOIN transaksi t ON m.id_mobil = t.id_mobil
INNER JOIN users u ON t.id_users = u.id_users
WHERE t.status_transaksi = 'Belum Selesai';
select * from mobil_dipinjam_view;

-- 2. View keuangan berdasarkan transaksi penyewaan dan perawatan:
CREATE VIEW keuangan_view AS
SELECT
    'Pemasukan' AS jenis_transaksi,
    SUM(total_biaya) AS total_pemasukan,
    COUNT(*) AS jumlah_data
FROM transaksi
UNION ALL
SELECT
    'Pengeluaran' AS jenis_transaksi,
    SUM(biaya) AS total_pengeluaran,
    COUNT(*) AS jumlah_data
FROM perawatan;
select * from keuangan_view;

-- ===============STORE PROCEDURE======================
-- 1. Prosedur untuk menambahkan mobil baru ke tabel mobil:
DELIMITER //
CREATE PROCEDURE tambah_mobil_baru(
    IN p_merk VARCHAR(50),
    IN p_model VARCHAR(50),
    IN p_tahun INT,
    IN p_warna VARCHAR(20),
    IN p_harga_perhari INT,
    IN p_status ENUM('Dipinjam','Tersedia', 'Perbaikan'),
    IN p_gambar VARCHAR(225)
)
BEGIN
    INSERT INTO mobil (merk, model, tahun, warna, harga_perhari, status, gambar)
    VALUES (p_merk, p_model, p_tahun, p_warna, p_harga_perhari, p_status, p_gambar);
END //
DELIMITER ;
CALL tambah_mobil_baru('Honda', 'CR-V', 2021, 'Merah', 800000, 'Tersedia', 'honda.jpg');
select * from mobil;

-- 2. procedure untuk hitung harga sewa & diskon (10%) yang sewa lebih dari 3hari 
DELIMITER //
CREATE PROCEDURE hitung_harga_sewa(
    IN p_id_mobil INT,
    IN p_tanggal_mulai DATE,
    IN p_tanggal_selesai DATE,
    OUT p_total_biaya INT,
    OUT p_diskon INT
)
BEGIN
    DECLARE v_lama_sewa INT;
    DECLARE v_harga_perhari INT;
    DECLARE v_total_biaya INT;
    DECLARE v_diskon INT;
    
    -- Menghitung lama sewa dalam hari
    SET v_lama_sewa = DATEDIFF(p_tanggal_selesai, p_tanggal_mulai) + 1;
    
    -- Mendapatkan harga perhari dari transaksi
    SELECT harga_perhari INTO v_harga_perhari
    FROM mobil
    WHERE id_mobil = p_id_mobil;
    -- Menghitung total biaya tanpa diskon
    SET v_total_biaya = v_harga_perhari * v_lama_sewa;
    -- Menghitung diskon jika sewa lebih dari 3 hari
    IF v_lama_sewa > 3 THEN
        SET v_diskon = (v_total_biaya * 10) / 100;
    ELSE
        SET v_diskon = 0;
    END IF;
    -- Menghitung total biaya setelah diskon
    SET v_total_biaya = v_total_biaya - v_diskon;
    -- Assign nilai output
    SET p_total_biaya = v_total_biaya;
    SET p_diskon = v_diskon;
END //
DELIMITER ;
SET @id_mobil = 1;
SET @tanggal_mulai = '2024-05-01';
SET @tanggal_selesai = '2024-05-02';
CALL hitung_harga_sewa(@id_mobil, @tanggal_mulai, @tanggal_selesai, @total_biaya, @diskon);
SELECT 
    m.merk, 
    m.model, 
    @tanggal_mulai AS tanggal_mulai,
    @tanggal_selesai AS tanggal_selesai,
    DATEDIFF(@tanggal_selesai, @tanggal_mulai) + 1 AS total_hari,
    m.harga_perhari,
    m.harga_perhari * (DATEDIFF(@tanggal_selesai, @tanggal_mulai) + 1) AS harga_sebelum_diskon,
    @diskon AS diskon,
    @total_biaya AS total_harga
FROM mobil m
WHERE m.id_mobil = @id_mobil;

-- 3. Prosedur total mobil sewaan dalam sebulan terakhir dengan harganya (dengan atau tanpa diskon)

DELIMITER //

CREATE PROCEDURE data_rental_sebulan()
BEGIN
  DECLARE tanggal_awal DATE;
  DECLARE tanggal_selesai DATE;

  -- Mengatur rentang tanggal untuk bulan lalu
  SET tanggal_selesai = LAST_DAY(CURRENT_DATE - INTERVAL 1 MONTH);
  SET tanggal_awal = DATE_SUB(tanggal_selesai, INTERVAL DAY(tanggal_selesai) - 1 DAY);

  -- Pilih data total mobil sewaan beserta harganya
  SELECT
    t.id_transaksi,
    u.username AS nama_pelanggan,
    m.merk,
    m.model,
    t.tanggal_mulai,
    t.tanggal_selesai,
    DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1 AS total_hari,
    m.harga_perhari,
    m.harga_perhari * (DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1) AS harga_tanpa_diskon,
    IF(DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1 > 3,
      ROUND(m.harga_perhari * (DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1) * 0.1),
      0) AS diskon_10_percent,
    IF(DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1 > 3,
      ROUND(m.harga_perhari * (DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1) * 0.9),
      m.harga_perhari * (DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1)) AS total_biaya_keseluruhan,
    CASE WHEN p.denda IS NULL THEN 0 ELSE p.denda END AS denda,
    IFNULL(ROUND(IF(DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1 > 3,
      m.harga_perhari * (DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1) * 0.9,
      m.harga_perhari * (DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1)) + IFNULL(p.denda, 0)),
      m.harga_perhari * (DATEDIFF(t.tanggal_selesai, t.tanggal_mulai) + 1)) AS total_biaya_setelah_denda
  FROM transaksi t
  INNER JOIN users u ON t.id_users = u.id_users
  INNER JOIN mobil m ON t.id_mobil = m.id_mobil
  LEFT JOIN pembayaran p ON t.id_transaksi = p.id_transaksi
  WHERE t.tanggal_mulai BETWEEN tanggal_awal AND tanggal_selesai;
END //

DELIMITER ;

-- Call the stored procedure to view the data
CALL data_rental_sebulan();

-- 4.  looping update_total_biaya_perawatan
ALTER TABLE mobil
ADD COLUMN total_biaya_perawatan INT DEFAULT 0;
DELIMITER //
CREATE PROCEDURE update_total_biaya_perawatan()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE mobil_id INT;
    DECLARE perawatan_biaya INT;
    -- Cursor untuk mendapatkan data perawatan untuk setiap mobil
    DECLARE cur CURSOR FOR 
        SELECT id_mobil, SUM(biaya) AS total_biaya_perawatan
        FROM perawatan
        GROUP BY id_mobil;
    -- Menandai akhir cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    read_loop: LOOP
        -- Baca data perawatan
        FETCH cur INTO mobil_id, perawatan_biaya;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- Update total biaya perawatan di tabel mobil
        UPDATE mobil SET total_biaya_perawatan = perawatan_biaya WHERE id_mobil = mobil_id;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;
-- Panggil prosedur untuk menjalankan loop
CALL update_total_biaya_perawatan();
select * from mobil;

-- ===============TRIGER======================
-- 1. triger mengatur tabel transaksi
--  Membuat tabel log untuk merekam perubahan data pada tabel transaksi
CREATE TABLE log_transaksi (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    record_id INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Triger untuk merekam penambahan data pada tabel transaksi
DELIMITER //
CREATE TRIGGER log_transaksi_insert AFTER INSERT ON transaksi
FOR EACH ROW
BEGIN
    INSERT INTO log_transaksi (action_type, record_id)
    VALUES ('INSERT', NEW.id_transaksi);
END //

-- Triger untuk merekam perubahan data pada tabel transaksi
CREATE TRIGGER log_transaksi_update AFTER UPDATE ON transaksi
FOR EACH ROW
BEGIN
    INSERT INTO log_transaksi (action_type, old_record_id, new_record_id)
    VALUES ('UPDATE', OLD.id_transaksi, NEW.id_transaksi);
END //

-- Triger untuk merekam penghapusan data pada tabel transaksi
CREATE TRIGGER log_transaksi_delete AFTER DELETE ON transaksi
FOR EACH ROW
BEGIN
    INSERT INTO log_transaksi (action_type, record_id)
    VALUES ('DELETE', OLD.id_transaksi);
END //
DELIMITER ;

-- 2. Trigger untuk memperbarui status mobil saat perawatan selesai
DELIMITER //
CREATE TRIGGER after_update_status_perawatan AFTER UPDATE ON perawatan
FOR EACH ROW
BEGIN
    -- Periksa apakah perawatan telah selesai
    IF NEW.status = 'Selesai' THEN
        -- Perbarui status mobil menjadi 'Tersedia' jika mobil telah diperbaiki
        UPDATE mobil
        SET status = 'Tersedia'
        WHERE id_mobil = NEW.id_mobil;
    END IF;
END //
DELIMITER ;
SELECT * FROM perawatan;
SELECT * FROM mobil;


