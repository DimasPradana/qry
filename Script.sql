SELECT
	*
FROM
	(
	SELECT
		a.NM_WP_SPPT AS Nama,
		a.KELURAHAN_WP_SPPT AS KELURAHAN,
		a.THN_PAJAK_SPPT AS tahun,
		a.PBB_YG_HARUS_DIBAYAR_SPPT AS pokok,
		COALESCE(b.denda, 0) AS denda,
		sum(a.PBB_YG_HARUS_DIBAYAR_SPPT + COALESCE(b.DENDA, 0)) AS total,
		a.STATUS_PEMBAYARAN_SPPT AS lunas
	FROM
		SPPT a
	LEFT JOIN VIEW_DENDA b ON
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
	WHERE
		a.KD_KECAMATAN = 997
		AND a.KD_KELURAHAN = 001
		AND a.KD_BLOK = 001
		AND a.NO_URUT = 0003
		--		AND a.STATUS_PEMBAYARAN_SPPT = 0
		AND a.THN_PAJAK_SPPT <= 2020
	GROUP BY
		a.NM_WP_SPPT,
		a.KELURAHAN_WP_SPPT,
		a.THN_PAJAK_SPPT,
		a.PBB_YG_HARUS_DIBAYAR_SPPT,
		b.DENDA,
		a.STATUS_PEMBAYARAN_SPPT
	ORDER BY
		a.THN_PAJAK_SPPT DESC)
WHERE
	rownum <= 11;

SELECT
	value
FROM
	"GV$DIAG_INFO"
WHERE
	name = 'Diag Alert';

SELECT
	a.STATUS_PEMBAYARAN_SPPT
FROM
	SPPT a
WHERE
	a.KD_KECAMATAN = 997
	AND a.KD_KELURAHAN = 001
	AND a.KD_BLOK = 001
	AND a.NO_URUT = 0003
	AND a.THN_PAJAK_SPPT = 2020;

SELECT
	*
FROM
	(
	SELECT
		a.THN_PAJAK_SPPT AS tahun,
		a.PBB_YG_HARUS_DIBAYAR_SPPT AS pokok,
		COALESCE(b.denda, 0) AS denda,
		sum(a.PBB_YG_HARUS_DIBAYAR_SPPT + COALESCE(b.DENDA, 0)) AS total
	FROM
		SPPT a
	LEFT JOIN VIEW_DENDA b ON
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
	WHERE
		a.KD_KECAMATAN = 997
		AND a.KD_KELURAHAN = 001
		AND a.KD_BLOK = 001
		AND a.NO_URUT = 0002
		AND a.STATUS_PEMBAYARAN_SPPT = 0
		AND a.THN_PAJAK_SPPT <= 2020
	GROUP BY
		a.THN_PAJAK_SPPT,
		a.PBB_YG_HARUS_DIBAYAR_SPPT,
		b.DENDA
	ORDER BY
		a.THN_PAJAK_SPPT DESC)
WHERE
	rownum <= 11;
--SELECT a.STATUS_PEMBAYARAN_SPPT
 SELECT
CASE
		WHEN a.STATUS_PEMBAYARAN_SPPT = 1 THEN 'Lunas'
		ELSE 'Tidak Lunas'
	END lunas
FROM
	SPPT a
WHERE
	a.KD_KECAMATAN = 997
	AND a.KD_KELURAHAN = 001
	AND a.KD_BLOK = 001
	AND a.NO_URUT = 0003
	AND a.THN_PAJAK_SPPT = 2020;

SELECT
	a.status_pembayaran_sppt AS lunas,
	a.nm_wp_sppt AS nama,
	b.nm_kelurahan AS kelurahan
FROM
	sppt a
LEFT JOIN VIEW_KELURAHAN b ON
	a.kd_kecamatan = b.kd_kecamatan
	AND a.kd_kelurahan = b.kd_kelurahan
WHERE
	a.KD_KECAMATAN = 997
	AND a.KD_KELURAHAN = 001
	AND a.KD_BLOK = 001
	AND a.NO_URUT = 0002
	AND a.thn_pajak_sppt = 2020;

SELECT
	'35-12-' || dop.KD_KECAMATAN || '-' || dop.KD_KELURAHAN || '-' || dop.KD_BLOK || '-' || dop.NO_URUT || '-0' AS nop,
	dsp.NM_WP AS nama
FROM
	DAT_OBJEK_PAJAK dop
LEFT JOIN DAT_SUBJEK_PAJAK dsp ON
	dop.SUBJEK_PAJAK_ID = dsp.SUBJEK_PAJAK_ID
WHERE
	dop.KD_KECAMATAN = 070
	AND dop.KD_KELURAHAN = 002
	AND dop.KD_BLOK = 008
	AND dop.NO_URUT = 0013;

SELECT
	*
FROM
	(
	SELECT
		a.THN_PAJAK_SPPT AS tahun,
		a.PBB_YG_HARUS_DIBAYAR_SPPT AS pokok,
		COALESCE(a.denda, 0) AS denda,
		sum(a.PBB_YG_HARUS_DIBAYAR_SPPT + COALESCE(a.DENDA, 0)) AS total
	FROM
		VIEW_DENDA a
	LEFT JOIN VIEW_DENDA b ON
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
	WHERE
		a.KD_KECAMATAN = 997
		AND a.KD_KELURAHAN = 001
		AND a.KD_BLOK = 001
		AND a.NO_URUT = 0002
		AND a.THN_PAJAK_SPPT <= 2020
	GROUP BY
		a.THN_PAJAK_SPPT,
		a.PBB_YG_HARUS_DIBAYAR_SPPT,
		a.DENDA
	ORDER BY
		a.THN_PAJAK_SPPT DESC)
WHERE
	rownum <= 11;

SELECT
	'35-12-' || s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '-' || s.KD_JNS_OP AS nop,
	s.THN_PAJAK_SPPT AS tahun,
	s.NM_WP_SPPT AS nama,
	s.PBB_YG_HARUS_DIBAYAR_SPPT AS tagihantahunperkenaan,
	s.STATUS_PEMBAYARAN_SPPT AS lunas
FROM
	SPPT s
WHERE
	s.KD_KECAMATAN = 997
	AND s.KD_KELURAHAN = 001
	AND s.KD_BLOK = 001
	AND s.NO_URUT = 0001
	AND s.KD_JNS_OP = 0
	AND s.THN_PAJAK_SPPT = 2020;

SELECT
	count(ns.KOTA_OP)
FROM
	NOP_SERTIFIKAT ns;
-- query untuk dapat keterangan dari sertifikat
 SELECT
	'3512' || dop.KD_KECAMATAN || dop.KD_KELURAHAN || dop.KD_BLOK || dop.NO_URUT || dop.KD_JNS_OP AS NOP,
	ns.NOP AS sertifikat_nop,
	ns.JENIS_HAK AS jenis_hak,
	ns.NOMOR_AKTA AS nomor_akta,
	ns.NOMOR_INDUK_BIDANG AS NIB
FROM
	DAT_OBJEK_PAJAK dop
RIGHT JOIN NOP_SERTIFIKAT ns ON
	ns.NOP = '3512' || dop.KD_KECAMATAN || dop.KD_KELURAHAN || dop.KD_BLOK || dop.NO_URUT || dop.KD_JNS_OP
WHERE
	dop.KD_KECAMATAN = 051
	AND dop.KD_KELURAHAN = 005
	AND dop.KD_BLOK = 007
	AND dop.NO_URUT = 0104 ;

SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 5000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 5000 AND 6000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 6000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 6001 AND 7000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 7000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 7001 AND 8000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 8000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 8001 AND 9000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 9000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 9001 AND 10000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 10000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 10001 AND 11000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 11000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 11001 AND 12000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan 12000' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 12001 AND 13000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'tagihan tidak masuk kategori' AS keterangan
FROM
	SPPT s2
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT NOT BETWEEN 5000 AND 13000
	AND s2.THN_PAJAK_SPPT = 2020
UNION
SELECT
	count(s2.KD_PROPINSI) AS jumlah,
	'seluruh WP' AS keterangan
FROM
	SPPT s2
WHERE
	s2.THN_PAJAK_SPPT = 2020;

SELECT
	count(s.KD_PROPINSI) AS jumlah,
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nominal
FROM
	SPPT s
WHERE
	s.NJOP_BUMI_SPPT > 1000000000
	AND s.THN_PAJAK_SPPT = 2020;

SELECT
	'35-12' || '-' || s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '-0' AS NOP,
	s.NM_WP_SPPT AS nama_wp,
	s.THN_PAJAK_SPPT AS tahun_pajak,
	s.PBB_YG_HARUS_DIBAYAR_SPPT AS nominal
FROM
	SPPT s
WHERE
	s.NJOP_BUMI_SPPT > 1000000000
	AND s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.THN_PAJAK_SPPT = 2020
ORDER BY
	NOP ASC;

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nominal
FROM
	pbb.SPPT s
WHERE
	s.THN_PAJAK_SPPT = 2020;
	
SELECT SUBJEK_PAJAK_ID AS NIK, NM_WP AS Nama, JALAN_WP AS Alamat
FROM DAT_SUBJEK_PAJAK dsp 
ORDER BY NM_WP ASC;


-- inventaris NOP pak kaban dan istri
 SELECT
	'3512' || dop.KD_KECAMATAN || dop.KD_KELURAHAN || dop.KD_BLOK || dop.NO_URUT || '0' AS NOP,
	DSP.NM_WP AS nama_subjek,
	dop.JALAN_OP AS alamat,
	vk.NM_KECAMATAN AS kecamatan,
	vk.NM_KELURAHAN AS kelurahan
FROM
	DAT_SUBJEK_PAJAK dsp
LEFT JOIN DAT_OBJEK_PAJAK dop ON
	dsp.SUBJEK_PAJAK_ID = dop.SUBJEK_PAJAK_ID
LEFT JOIN VIEW_KELURAHAN vk ON
	dop.KD_KECAMATAN = vk.KD_KECAMATAN
	AND dop.KD_KELURAHAN = vk.KD_KELURAHAN
WHERE
	DSP.SUBJEK_PAJAK_ID IN ('3512062711680001              ',
	'3512066201700001              ');


DELETE FROM DAFNOM_PIUTANG dp WHERE dp.THN_PEMBENTUKAN =2020;

INSERT
	INTO
	PBB.PENGGUNA (USERNAME,
	PASS,
	NIP,
	NAMA,
	HAK,
	STATUS)
VALUES('JAELANI',
'32a8decdf6bb132c983f8c3748ea892f',
'888888888',
'JAELANI',
'PENGOLAHAN',
'1');


SELECT
	'35-12' || '-' || s2.KD_KECAMATAN || '-' || s2.KD_KELURAHAN || '-' || s2.KD_BLOK || '-' || s2.NO_URUT || '-0' AS NOP,
	s2.PBB_YG_HARUS_DIBAYAR_SPPT AS sppt,
	ps.JML_SPPT_YG_DIBAYAR AS ps_bayar,
	ps.DENDA_SPPT AS ps_denda,
	ps.JML_SPPT_YG_DIBAYAR -ps.DENDA_SPPT AS pembayaran,
	s2.STATUS_PEMBAYARAN_SPPT AS status
FROM
	SPPT s2
LEFT JOIN PEMBAYARAN_SPPT ps ON
	s2.KD_KECAMATAN = ps.KD_KECAMATAN
	AND s2.KD_KELURAHAN = ps.KD_KELURAHAN
	AND s2.KD_BLOK = ps.KD_BLOK
	AND s2.NO_URUT = ps.NO_URUT
	AND s2.THN_PAJAK_SPPT = ps.THN_PAJAK_SPPT
WHERE
	s2.PBB_YG_HARUS_DIBAYAR_SPPT != (ps.JML_SPPT_YG_DIBAYAR - ps.DENDA_SPPT)
	AND s2.THN_PAJAK_SPPT = 2019
ORDER BY STATUS asc;


SELECT sum(ps.PBB_YG_HARUS_DIBAYAR_SPPT )
FROM SPPT ps 
WHERE ps.THN_PAJAK_SPPT =2020; 

SELECT
	nvl(sum(stts), 0),
	nvl(sum(pokok), 0)
FROM
	(
	SELECT
		kel.kd_kelurahan,
		kel.nm_kelurahan,
		nvl(sum(penerimaan.stts), 0) AS stts,
		nvl(sum(penerimaan.pokok), 0) AS pokok
	FROM
		(
		SELECT
			*
		FROM
			ref_kelurahan
		WHERE
			kd_kecamatan = :kd_kec) kel
	LEFT JOIN (
		SELECT
			kd_propinsi,
			kd_dati2,
			kd_kecamatan,
			kd_kelurahan,
			count(*) AS stts,
			sum(pbb_yg_harus_dibayar_sppt) AS pokok
		FROM
			(
			SELECT
				*
			FROM
				view_sppt_op_dimas
			WHERE
				kd_kecamatan = :kd_kec
--				AND KD_KELURAHAN = :kd_kel
				AND status_pembayaran_sppt = 0
				AND status_dafnom_piutang IN ('1',
				'11')
				-- 				and thn_pajak_sppt='$(tahun)'
				AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
		UNION
			SELECT
				*
			FROM
				view_sppt_op_dimas
			WHERE
				kd_kecamatan = :kd_kec
--				AND KD_KELURAHAN = :kd_kel
				-- 				and thn_pajak_sppt='$(tahun)'
				AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
				--                    and status_dafnom_piutang in ('1', '11') -- tambahan
				AND KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT IN (
				SELECT
					KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT
				FROM
					PEMBAYARAN_SPPT
				WHERE
					kd_kecamatan = :kd_kec
--					AND KD_KELURAHAN = :kd_kel
					-- 				and thn_pajak_sppt='$(tahun)'
					AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
					--					AND JENIS_BAYAR != 0
					AND TGL_PEMBAYARAN_SPPT > TO_DATE(:tgl_akhir, 'DD/MM/YYYY') ) ) view_sppt_op_dimas
		GROUP BY
			kd_propinsi,
			kd_dati2,
			kd_kecamatan,
			kd_kelurahan) penerimaan ON
		kel.kd_propinsi = penerimaan.kd_propinsi
		AND kel.kd_dati2 = penerimaan.kd_dati2
		AND kel.kd_kecamatan = penerimaan.kd_kecamatan
		AND kel.kd_kelurahan = penerimaan.kd_kelurahan
		--             group by kel.kd_kelurahan,kel.nm_kelurahan order by kel.kd_kelurahan;

		GROUP BY kel.kd_kelurahan,
		kel.nm_kelurahan
	ORDER BY
		kel.kd_kelurahan);
		

SELECT '35-12-'||s.KD_KECAMATAN ||'-'||s.KD_KELURAHAN ||'-'||s.KD_BLOK ||'-'||s.NO_URUT ||'-0' AS nop,
s.NM_WP_SPPT AS nama,
s.LUAS_BUMI_SPPT AS luas, s.PBB_YG_HARUS_DIBAYAR_SPPT AS nominal
FROM SPPT s 
WHERE s.THN_PAJAK_SPPT =2019 AND s.KD_KECAMATAN =050 AND s.KD_KELURAHAN =002;

