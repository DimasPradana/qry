/*TODO
 *** jika di server lokal lebih banyak daripada di acuan(audited)
 * 1. hitung selisih antara audited dikurangi nominal server lokal (set var &nominal)
 * 2. jika hasilnya minus, maka cari nominal diatas *nominal (pakai samid_1)
 * 3. ambil 1 NOP dengan tagihan yang lebih besar dari  *nominal lalu kurangkan pbb_yg_harus_dibayar dengan *nominal
 * 4. jika sudah di commit, lalu cek dengan menggunakan samid_2
 * 
 *** jika di server lokal lebih sedikit daripada di audited do opposite at step 2 and 3 (__->NO TESTED YET<--__)
 *
 *
 *** PS: batas atas untuk tahun pajak adalah 2017
*/

-- TODO menu monitoring - tunggakan samid_2
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
				AND KD_KELURAHAN = :kd_kel
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
				AND KD_KELURAHAN = :kd_kel
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
					AND KD_KELURAHAN = :kd_kel
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
	
	
--TODO cari yg statusnya belum lunas tapi ada di table pembayaran
 UPDATE
	sppt a
SET
	a.STATUS_PEMBAYARAN_SPPT = 1
	--select *
	--from sppt a

	WHERE a.STATUS_PEMBAYARAN_SPPT = 0
	AND EXISTS(
	SELECT
		*
	FROM
		PEMBAYARAN_SPPT b
	WHERE
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT );

SELECT
	count(KD_PROPINSI),
	'sppt' AS keterangan
FROM
	PBB.SPPT a
WHERE
	a.STATUS_DAFNOM_PIUTANG IN ('1')
UNION
SELECT
	count(KD_PROPINSI),
	'dafnom' AS keterangan
FROM
	PBB.DAFNOM_PIUTANG b
WHERE
	b.THN_PEMBENTUKAN = '2013'
UNION
SELECT
	count(KD_PROPINSI),
	'selisih sppt' AS keterangan
FROM
	PBB.SPPT a
WHERE
	a.STATUS_DAFNOM_PIUTANG IN ('0');

--TODO update status dafnom piutang = 0
 UPDATE
	sppt a
SET
	a.STATUS_DAFNOM_PIUTANG = 0
WHERE
	a.STATUS_DAFNOM_PIUTANG IS NULL
	AND a.THN_PAJAK_SPPT BETWEEN '1994' AND '2013';

--TODO tampilkan yang dafnom = 0 dan status pembayaran 1 dan 0
 SELECT
	count(s.KD_PROPINSI),
	'belum lunas' AS jumlah
FROM
	SPPT s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.STATUS_DAFNOM_PIUTANG = 0;

--TODO tampilkan yang dafnom = 0 dan status pembayaran 1 dan 0
 SELECT
	count(s.KD_PROPINSI),
	'lunas' AS jumlah
FROM
	SPPT s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 1
	AND s.STATUS_DAFNOM_PIUTANG = 0;

--TODO update status pembayaran = 4
 UPDATE
	PBB.SPPT p
SET
	p.STATUS_PEMBAYARAN_SPPT = 4
WHERE
	p.STATUS_DAFNOM_PIUTANG = 0
	AND p.STATUS_PEMBAYARAN_SPPT = 0;
--TODO update status pembayaran = 3
 UPDATE
	PBB.SPPT p
SET
	p.STATUS_PEMBAYARAN_SPPT = 3
WHERE
	p.STATUS_DAFNOM_PIUTANG = 0
	AND p.STATUS_PEMBAYARAN_SPPT = 1;
--TODO count status_dafnom = 1
 SELECT
	count(a.KD_PROPINSI) AS banyak,
	'belum lunas' AS status
FROM
	PBB.SPPT a
WHERE
	a.STATUS_DAFNOM_PIUTANG = 0
	AND a.STATUS_PEMBAYARAN_SPPT = 4
UNION
SELECT
	count(a.KD_PROPINSI) AS banyak,
	'lunas' AS status
FROM
	PBB.SPPT a
WHERE
	a.STATUS_DAFNOM_PIUTANG = 0
	AND a.STATUS_PEMBAYARAN_SPPT = 3;
-- TODO hitung piutang tahun 1993 - 2013
 SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	'1994 - 2013' AS keterangan
FROM
	sppt s
WHERE
	s.STATUS_DAFNOM_PIUTANG = 1
	AND s.STATUS_PEMBAYARAN_SPPT = 0
UNION
SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	'2014 - 2018' AS keterangan
FROM
	sppt s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.STATUS_DAFNOM_PIUTANG = 11
	AND s.THN_PAJAK_SPPT BETWEEN '2014' AND '2018'
UNION
SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	'2019' AS keterangan
FROM
	sppt s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.STATUS_DAFNOM_PIUTANG = 11
	AND s.THN_PAJAK_SPPT = '2019';
-- TODO tampilkan NOP
 SELECT
	*
FROM
	(
	SELECT
		*
	FROM
		view_sppt_op_dimas
	WHERE
		kd_kecamatan = '$(kec)'
		AND kd_kelurahan = '$(kel)'
		AND status_pembayaran_sppt <> 1
		AND STATUS_DAFNOM_PIUTANG = 1
		AND thn_pajak_sppt = '$(thnpajak)'
UNION
	SELECT
		*
	FROM
		view_sppt_op_dimas
	WHERE
		kd_kecamatan = '$(kec)'
		AND kd_kelurahan = '$(kel)'
		AND STATUS_DAFNOM_PIUTANG = 1
		AND thn_pajak_sppt = '$(thnpajak)'
		AND KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT IN (
		SELECT
			KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT
		FROM
			PEMBAYARAN_SPPT
		WHERE
			kd_kecamatan = '$(kec)'
			AND kd_kelurahan = '$(kel)'
			AND thn_pajak_sppt = '$(thnpajak)'
			AND TGL_PEMBAYARAN_SPPT > TO_DATE('$(btstanggal)', 'DD/MM/YYYY') ) );

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	DAFNOM_PIUTANG s
WHERE
	s.THN_PEMBENTUKAN = 2013;
-- TODO VERI 900
 SELECT
	count(v.KD_PROPINSI)
FROM
	VERI_900 v;
-- select a.KD_PROPINSI||a.KD_DATI2||a.KD_KECAMATAN||a.KD_KELURAHAN||a.KD_BLOK||a.NO_URUT||'-'||a.THN_PAJAK_SPPT
 SELECT
	count(a.KD_PROPINSI)
FROM
	VERI_900 a
WHERE
	EXISTS(
	SELECT
		*
	FROM
		sppt b
	WHERE
		b.STATUS_DAFNOM_PIUTANG = 2
		AND a.KD_PROPINSI = b.KD_PROPINSI
		AND a.KD_DATI2 = b.KD_DATI2
		AND a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.PBB_YG_HARUS_DIBAYAR_SPPT = b.PBB_YG_HARUS_DIBAYAR_SPPT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT);
-- TODO sandingkan pokok
 SELECT
	'35-12-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '/' || a.PBB_YG_HARUS_DIBAYAR_SPPT || '/' || a.THN_PAJAK_SPPT AS SPPT,
	'35-12-' || b.KD_KECAMATAN || '-' || b.KD_KELURAHAN || '-' || b.KD_BLOK || '-' || b.NO_URUT || '/' || b.PBB_YG_HARUS_DIBAYAR_SPPT || '/' || b.THN_PAJAK_SPPT AS UJI
FROM
	sppt a
LEFT JOIN VERI_900 b ON
	a.KD_PROPINSI = b.KD_PROPINSI
	AND a.KD_DATI2 = b.KD_DATI2
	AND a.KD_KECAMATAN = b.KD_KECAMATAN
	AND a.KD_KELURAHAN = b.KD_KELURAHAN
	AND a.KD_BLOK = b.KD_BLOK
	AND a.NO_URUT = b.NO_URUT
	AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
WHERE
	a.PBB_YG_HARUS_DIBAYAR_SPPT != b.PBB_YG_HARUS_DIBAYAR_SPPT
	AND a.STATUS_DAFNOM_PIUTANG = 2
	AND a.STATUS_PEMBAYARAN_SPPT IN ('0',
	'1');

SELECT
	count(*)
FROM
	SPPT a
WHERE
	a.STATUS_DAFNOM_PIUTANG = 1;

UPDATE
	SPPT a
SET
	STATUS_DAFNOM_PIUTANG = 2
WHERE
	a.STATUS_DAFNOM_PIUTANG = 1
	AND EXISTS(
	SELECT
		*
	FROM
		VERI_900 b
	WHERE
		a.KD_PROPINSI = b.KD_PROPINSI
		AND a.KD_DATI2 = b.KD_DATI2
		AND a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT);

UPDATE
	SPPT a
SET
	a.STATUS_PEMBAYARAN_SPPT = 5
WHERE
	a.STATUS_DAFNOM_PIUTANG = 2;

SELECT
	*
FROM
	SPPT a
WHERE
	a.STATUS_DAFNOM_PIUTANG = 2
	AND a.KD_PROPINSI || a.KD_DATI2 || a.KD_KECAMATAN || a.KD_KELURAHAN || a.KD_BLOK || a.NO_URUT || a.THN_PAJAK_SPPT NOT IN (
	SELECT
		b.KD_PROPINSI || b.KD_DATI2 || b.KD_KECAMATAN || b.KD_KELURAHAN || b.KD_BLOK || b.NO_URUT || b.THN_PAJAK_SPPT
	FROM
		PEMBAYARAN_SPPT b
	WHERE
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT );

UPDATE
	SPPT a
SET
	a.STATUS_PEMBAYARAN_SPPT = 5
WHERE
	a.STATUS_DAFNOM_PIUTANG = 2
	AND a.KD_PROPINSI || a.KD_DATI2 || a.KD_KECAMATAN || a.KD_KELURAHAN || a.KD_BLOK || a.NO_URUT || a.THN_PAJAK_SPPT IN (
	SELECT
		b.KD_PROPINSI || b.KD_DATI2 || b.KD_KECAMATAN || b.KD_KELURAHAN || b.KD_BLOK || b.NO_URUT || b.THN_PAJAK_SPPT
	FROM
		PEMBAYARAN_SPPT b
	WHERE
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT );

SELECT
	count(a.KD_PROPINSI)
FROM
	SPPT a
WHERE
	a.STATUS_PEMBAYARAN_SPPT IN ('5',
	'6');

SELECT
	count(s.KD_PROPINSI)
FROM
	SPPT s
WHERE
	s.STATUS_DAFNOM_PIUTANG IN ('1',
	'2');

SELECT
	*
FROM
	VERI_900 a
WHERE
	NOT EXISTS(
	SELECT
		*
	FROM
		sppt b
	WHERE
		a.KD_PROPINSI = b.KD_PROPINSI
		AND a.KD_DATI2 = b.KD_DATI2
		AND a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
		AND b.STATUS_DAFNOM_PIUTANG = 2);

SELECT
	count(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nom,
	'sppt' AS ket
FROM
	SPPT s
WHERE
	s.STATUS_DAFNOM_PIUTANG = 2
	-- where s.STATUS_DAFNOM_PIUTANG = 2 and s.STATUS_PEMBAYARAN_SPPT <> 9
UNION
SELECT
	sum(a.PBB_YG_HARUS_DIBAYAR_SPPT) AS nom,
	'veri' AS ket
FROM
	VERI_900 a
UNION
SELECT
	sum(b.PBB_YG_HARUS_DIBAYAR_SPPT) AS nom,
	'bersih' AS ket
FROM
	sppt b
WHERE
	b.STATUS_DAFNOM_PIUTANG = 3
UNION
SELECT
	sum(c.PBB_YG_HARUS_DIBAYAR_SPPT) AS nom,
	'tunggakan' AS ket
FROM
	sppt c
WHERE
	c.STATUS_DAFNOM_PIUTANG = 1;

UPDATE
	sppt s
SET
	s.STATUS_DAFNOM_PIUTANG = 3
WHERE
	s.STATUS_DAFNOM_PIUTANG = 2
	AND s.STATUS_PEMBAYARAN_SPPT <> 9;

UPDATE
	SPPT s
SET
	s.STATUS_DAFNOM_PIUTANG = 11
WHERE
	s.THN_PAJAK_SPPT BETWEEN '2014' AND '2019';
-- TODO dimas
 SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nominal,
	'sppt tahun pajak 94 -2013' AS keterangan
FROM
	SPPT s
WHERE
	s.STATUS_DAFNOM_PIUTANG = 1
	AND s.STATUS_PEMBAYARAN_SPPT != 9
	AND s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.THN_PAJAK_SPPT BETWEEN '1994' AND '2013'
UNION
SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nominal,
	'sppt tahun pajak 2014 - 2018' AS keterangan
FROM
	SPPT s
WHERE
	s.THN_PAJAK_SPPT BETWEEN '2014' AND '2018'
	AND s.STATUS_PEMBAYARAN_SPPT = 0;
-- union
-- select sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) as nominal, 'lunas tahun pajak 94 -2013' as keterangan
-- from SPPT s
-- where s.STATUS_DAFNOM_PIUTANG  = 1 and s.THN_PAJAK_SPPT between '1994' and '2013' and s.STATUS_PEMBAYARAN_SPPT =1
-- union
-- select sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) as nominal, 'belum lunas  tahun pajak 94 -2013' as keterangan
-- from SPPT s
-- where s.STATUS_DAFNOM_PIUTANG  = 1 and s.THN_PAJAK_SPPT between '1994' and '2013' and s.STATUS_PEMBAYARAN_SPPT = 0;
-- TODO lunaskan sesuai dengan VERI_900

-- select sum(a.PBB_YG_HARUS_DIBAYAR_SPPT)
 SELECT
	'35-12-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '/' || a.THN_PAJAK_SPPT || '/' || a.PBB_YG_HARUS_DIBAYAR_SPPT AS SPPT
FROM
	SPPT a
WHERE
	a.STATUS_DAFNOM_PIUTANG = 2
	AND a.STATUS_PEMBAYARAN_SPPT = 0
	AND a.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 3000 AND 113556
	AND a.THN_PAJAK_SPPT BETWEEN '1994' AND '2013';

UPDATE
	sppt a
SET
	a.STATUS_PEMBAYARAN_SPPT = 9
WHERE
	a.KD_KECAMATAN = 120
	AND a.KD_KELURAHAN = 003
	AND a.STATUS_DAFNOM_PIUTANG = 2
	AND a.STATUS_PEMBAYARAN_SPPT = 0
	AND a.THN_PAJAK_SPPT BETWEEN '1994' AND '2013';
-- update SPPT a set a.STATUS_PEMBAYARAN_SPPT = 7
 SELECT
	sum(a.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	sppt a
WHERE
	a.STATUS_DAFNOM_PIUTANG = 2
	AND a.KD_KECAMATAN = 140
	AND a.KD_KELURAHAN = 008
	AND a.THN_PAJAK_SPPT = 2013
UNION
SELECT
	sum(a.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	sppt a
WHERE
	a.STATUS_DAFNOM_PIUTANG = 2
	AND a.KD_KECAMATAN = 140
	AND a.KD_KELURAHAN = 008
	AND a.THN_PAJAK_SPPT = 2009;

DROP TABLE VERI_900;
-- select count(a.KD_PROPINSI) from sppt a
 UPDATE
	sppt a
SET
	a.STATUS_DAFNOM_PIUTANG = 1
WHERE
	a.STATUS_DAFNOM_PIUTANG = 2;
-- TODO di SPPT lunas yg tidak ada tanggal bayar
 SELECT
	s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '/' || s.THN_PAJAK_SPPT AS NOP
	-- select count(*)

	FROM SPPT s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 1
	AND NOT EXISTS(
	SELECT
		*
	FROM
		PEMBAYARAN_SPPT p
	WHERE
		s.KD_KECAMATAN = p.KD_KECAMATAN
		AND s.KD_KELURAHAN = p.KD_KELURAHAN
		AND s.KD_BLOK = p.KD_BLOK
		AND s.NO_URUT = p.NO_URUT
		AND s.THN_PAJAK_SPPT = p.THN_PAJAK_SPPT);

SELECT
	count(*)
FROM
	PEMBAYARAN_SPPT_2 a;

UPDATE
	DAT_OBJEK_PAJAK d
SET
	d.KD_JNS_OP = 0
WHERE
	d.KD_JNS_OP = 9;

SELECT
	DISTINCT *
FROM
	PEMBAYARAN_SPPT_2 a
WHERE
	a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '/' || a.THN_PAJAK_SPPT IN (
	SELECT
		s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '/' || s.THN_PAJAK_SPPT
	FROM
		SPPT s
	WHERE
		s.STATUS_PEMBAYARAN_SPPT = 1
		AND NOT EXISTS(
		SELECT
			*
		FROM
			PEMBAYARAN_SPPT p
		WHERE
			s.KD_KECAMATAN = p.KD_KECAMATAN
			AND s.KD_KELURAHAN = p.KD_KELURAHAN
			AND s.KD_BLOK = p.KD_BLOK
			AND s.NO_URUT = p.NO_URUT
			AND s.THN_PAJAK_SPPT = p.THN_PAJAK_SPPT) );
-- select a.KD_KECAMATAN||'-'||a.KD_KELURAHAN||'-'||a.KD_BLOK||'-'||a.NO_URUT||'-'||a.THN_PAJAK_SPPT as nop, count(a.KD_KECAMATAN||'-'||a.KD_KELURAHAN||'-'||a.KD_BLOK||'-'||a.NO_URUT||'-'||a.THN_PAJAK_SPPT) as hitung
 SELECT
	a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '/' || a.THN_PAJAK_SPPT || '/' || a.PEMBAYARAN_SPPT_KE AS nop,
	count(*) AS hitung
FROM
	PEMBAYARAN_SPPT_2 a
GROUP BY
	a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '/' || a.THN_PAJAK_SPPT || '/' || a.PEMBAYARAN_SPPT_KE
HAVING
	COUNT(*) > 1;
-- TODO hapus data pada pembayaran_sppt_2
-- pake golang

-- TODO 700 juta
 SELECT
	s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '/' || s.PBB_YG_HARUS_DIBAYAR_SPPT || '/' || s.THN_PAJAK_SPPT AS NOP
FROM
	sppt s
WHERE
	s.THN_PAJAK_SPPT BETWEEN '1994' AND '2013'
	AND s.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN 10000 AND 10000000
	AND STATUS_DAFNOM_PIUTANG = 1;

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	sppt s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.STATUS_DAFNOM_PIUTANG IN ('1',
	'11');

SELECT
	sum(a.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	sppt a
WHERE
	a.THN_PAJAK_SPPT = 2019;
-- update sppt s set s.STATUS_PEMBAYARAN_SPPT = 1
 SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	'baku' AS ket
	-- select s.KD_KECAMATAN||'-'||s.KD_KELURAHAN||'-'||s.KD_BLOK||'-'||s.NO_URUT||'/'||s.PBB_YG_HARUS_DIBAYAR_SPPT

	FROM sppt s
WHERE
	s.THN_PAJAK_SPPT = 2019
UNION
SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	'lunas' AS ket
	-- select s.KD_KECAMATAN||'-'||s.KD_KELURAHAN||'-'||s.KD_BLOK||'-'||s.NO_URUT||'/'||s.PBB_YG_HARUS_DIBAYAR_SPPT

	FROM sppt s
WHERE
	s.THN_PAJAK_SPPT = 2019
	AND s.STATUS_PEMBAYARAN_SPPT = 1
UNION
SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	'belum lunas' AS ket
	-- select s.KD_KECAMATAN||'-'||s.KD_KELURAHAN||'-'||s.KD_BLOK||'-'||s.NO_URUT||'/'||s.PBB_YG_HARUS_DIBAYAR_SPPT

	FROM sppt s
WHERE
	s.THN_PAJAK_SPPT = 2019
	AND s.STATUS_PEMBAYARAN_SPPT = 0;
-- TODO cari nominal yang mendekati neraca samid_1
 SELECT
	s.KD_KECAMATAN,
	s.KD_KELURAHAN,
	s.KD_BLOK,
	s.NO_URUT,
	s.THN_PAJAK_SPPT,
	s.PBB_YG_HARUS_DIBAYAR_SPPT,
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS total
FROM
	sppt s
WHERE
	s.KD_KECAMATAN = '031'
	AND s.KD_KELURAHAN ='005'
	AND s.THN_PAJAK_SPPT BETWEEN '1994' AND '2017'
	AND s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.STATUS_DAFNOM_PIUTANG in (1,11)
GROUP BY
	s.KD_KECAMATAN,
	s.KD_KELURAHAN,
	s.KD_BLOK,
	s.NO_URUT,
	s.THN_PAJAK_SPPT,
	s.PBB_YG_HARUS_DIBAYAR_SPPT
HAVING
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) > 90000
ORDER BY
	total DESC;

SELECT
	a.KD_KECAMATAN,
	a.KD_KELURAHAN,
	a.KD_BLOK,
	a.NO_URUT,
	a.THN_PAJAK_SPPT,
	sum(a.PBB_YG_HARUS_DIBAYAR_SPPT) AS total
FROM
	SPPT a
WHERE
	a.STATUS_PEMBAYARAN_SPPT = 0
	AND a.STATUS_DAFNOM_PIUTANG = 1
	AND a.THN_PAJAK_SPPT BETWEEN '1994' AND '2000'
GROUP BY
	a.KD_KECAMATAN,
	a.KD_KELURAHAN,
	a.KD_BLOK,
	a.NO_URUT,
	a.THN_PAJAK_SPPT
HAVING
	sum(a.PBB_YG_HARUS_DIBAYAR_SPPT) < 10000000;
-- update SPPT s set s.STATUS_PEMBAYARAN_SPPT =1
 SELECT
	count(*)
FROM
	sppt s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 3;

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	sppt s
WHERE
	s.KD_KECAMATAN = 100
	AND s.THN_PAJAK_SPPT BETWEEN '1994' AND '2013'
	AND s.STATUS_DAFNOM_PIUTANG = 1
	AND s.STATUS_PEMBAYARAN_SPPT = 0;
-- select s.NO_URUT,  s.PBB_YG_HARUS_DIBAYAR_SPPT
-- select sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) as nominal, count(s.PBB_YG_HARUS_DIBAYAR_SPPT) as jumlah_wp

-- from sppt s
 UPDATE
	sppt s
SET
	s.STATUS_PEMBAYARAN_SPPT = 1
WHERE
	s.KD_KECAMATAN = '$(kec)'
	AND s.KD_KELURAHAN = '$(kel)'
	AND s.THN_PAJAK_SPPT = '$(thn)'
	AND s.STATUS_DAFNOM_PIUTANG = 1
	AND s.STATUS_PEMBAYARAN_SPPT = 0;
-- TODO faruk

-- select sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
 SELECT
	s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '/' || s.PBB_YG_HARUS_DIBAYAR_SPPT || '/' || s.THN_PAJAK_SPPT
FROM
	sppt s
WHERE
	s.KD_KECAMATAN = '$(kec)'
	AND s.THN_PAJAK_SPPT BETWEEN '$(thnawal)' AND '$(thnakhir)'
	--   and s.THN_PAJAK_SPPT = '$(thn)'
	AND s.STATUS_DAFNOM_PIUTANG IN ('1',
	'11')
	--   and s.KD_KELURAHAN = '$(kel)'
	--      and s.KD_BLOK = '$(blok)'
	--     and s.KD_BLOK between '017' and '018'
	-- and s.NO_URUT between '0001' and '0010'
	--   and s.NO_URUT ='$(urut)'
	AND s.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN '120000' AND '500000'
	AND s.STATUS_PEMBAYARAN_SPPT = 0
	AND NOT EXISTS(
	SELECT
		*
	FROM
		PEMBAYARAN_SPPT p
	WHERE
		p.KD_PROPINSI = s.KD_PROPINSI
		AND p.KD_DATI2 = s.KD_DATI2
		AND p.KD_KECAMATAN = s.KD_KECAMATAN
		AND p.KD_KELURAHAN = s.KD_KELURAHAN
		AND p.KD_BLOK = s.KD_BLOK
		AND p.NO_URUT = s.NO_URUT
		AND p.THN_PAJAK_SPPT = s.THN_PAJAK_SPPT )
ORDER BY
	s.PBB_YG_HARUS_DIBAYAR_SPPT DESC;

SELECT
	s.NO_URUT,
	s.PBB_YG_HARUS_DIBAYAR_SPPT
FROM
	sppt s
WHERE
	s.KD_KECAMATAN = 100
	AND s.PBB_YG_HARUS_DIBAYAR_SPPT < 10000
	AND s.THN_PAJAK_SPPT = 2001
	AND s.STATUS_DAFNOM_PIUTANG = 1
	AND s.STATUS_PEMBAYARAN_SPPT = 0;
-- TODO dimas 2
 SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	count(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	sppt s
	-- update sppt s set s.STATUS_PEMBAYARAN_SPPT = 1

	WHERE s.KD_KECAMATAN = '$(kec)'
	--   and s.KD_KELURAHAN between '001' and '001'
	--   and s.KD_KELURAHAN = '$(kel)'
	--   and s.THN_PAJAK_SPPT between '$(thnawal)' and '$(thnakhir)'
	AND s.THN_PAJAK_SPPT = '$(thn)'
	AND s.STATUS_DAFNOM_PIUTANG IN ('1',
	'11')
	--      and s.KD_BLOK = '$(blok)'
	--     and s.KD_BLOK between '024' and '025'
	--     ' and '004'
	-- and s.NO_URUT between '0001' and '0037'
	--   and s.NO_URUT ='$(urut)'
	AND s.STATUS_PEMBAYARAN_SPPT = 1
	AND NOT EXISTS(
	SELECT
		*
	FROM
		PEMBAYARAN_SPPT p
	WHERE
		p.KD_PROPINSI = s.KD_PROPINSI
		AND p.KD_DATI2 = s.KD_DATI2
		AND p.KD_KECAMATAN = s.KD_KECAMATAN
		AND p.KD_KELURAHAN = s.KD_KELURAHAN
		AND p.KD_BLOK = s.KD_BLOK
		AND p.NO_URUT = s.NO_URUT
		AND p.THN_PAJAK_SPPT = s.THN_PAJAK_SPPT );

SELECT
	count(*)
FROM
	PEMBAYARAN_SPPT s
WHERE
	s.KD_KECAMATAN = 100
	AND s.KD_KELURAHAN = 002
	AND s.THN_PAJAK_SPPT = 2001;

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	sppt s
WHERE
	s.KD_KECAMATAN = 100
	AND s.KD_KELURAHAN = 003
	AND s.THN_PAJAK_SPPT = '2001'
	AND s.STATUS_DAFNOM_PIUTANG = 1;

SELECT
	*
FROM
	sppt a
WHERE
	a.PBB_YG_HARUS_DIBAYAR_SPPT BETWEEN '1000' AND '5000'
	AND a.STATUS_DAFNOM_PIUTANG = 1
	AND a.STATUS_PEMBAYARAN_SPPT = 0
	AND a.KD_KECAMATAN = 100;

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	SPPT s
WHERE
	s.TGL_CETAK_SPPT BETWEEN to_date('01/01/2019', 'dd/mm/yyyy') AND to_date('31/03/2019', 'dd/mm/yyyy')
	AND s.KD_KECAMATAN = 111
	AND THN_PAJAK_SPPT = 2019;
-- TODO faruk 2
 SELECT
	*
FROM
	sppt s
WHERE
	s.KD_KECAMATAN = '$(kec)'
	AND s.KD_KELURAHAN = '$(kel)'
	AND s.KD_BLOK = '$(blok)'
	AND s.NO_URUT = '$(urut)'
	AND s.THN_PAJAK_SPPT = '$(thn)'
	AND s.STATUS_PEMBAYARAN_SPPT = 0;
-- and s.THN_PAJAK_SPPT between '$(thn_awal)' and '$(thn_akhir)' ;

-- TODO faruk 3
 SELECT
	count(*),
	'ada di pembayaran' AS keterangan
FROM
	SPPT a
WHERE
	a.KD_KECAMATAN = 060
	--   and a.STATUS_DAFNOM_PIUTANG in ('1','11')
	AND a.THN_PAJAK_SPPT = 2014
	--   and a.STATUS_PEMBAYARAN_SPPT = 1
	AND EXISTS(
	SELECT
		*
	FROM
		PEMBAYARAN_SPPT b
	WHERE
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
		AND a.KD_PROPINSI = b.KD_PROPINSI
		AND a.KD_DATI2 = b.KD_DATI2 )
UNION
SELECT
	count(*),
	'tidak ada di pembayaran' AS keterangan
FROM
	SPPT a
WHERE
	a.KD_KECAMATAN = 060
	--   and a.STATUS_DAFNOM_PIUTANG in ('1','11')
	AND a.THN_PAJAK_SPPT = 2014
	--   and a.STATUS_PEMBAYARAN_SPPT = 1
	AND NOT EXISTS(
	SELECT
		*
	FROM
		PEMBAYARAN_SPPT b
	WHERE
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
		AND a.KD_PROPINSI = b.KD_PROPINSI
		AND a.KD_DATI2 = b.KD_DATI2 )
UNION
SELECT
	count(*),
	'semua SPPT' AS keterangan
FROM
	sppt a
WHERE
	a.KD_KECAMATAN = 060
	--   and a.STATUS_DAFNOM_PIUTANG in ('1','11')
	AND a.THN_PAJAK_SPPT = 2014;
-- and a.STATUS_PEMBAYARAN_SPPT = 1;

-- TODO Penerimaan pembayaran detail
 SELECT
	kel.kd_kelurahan,
	kel.nm_kelurahan,
	nvl(sum(penerimaan.stts_tahun_0), 0) AS stts_tahun_2019,
	--        nvl(sum(penerimaan.jum_tahun_0), 0)  as jum_tahun_0,
	--        nvl(sum(penerimaan.denda_0), 0)      as denda_0,
 nvl(sum(penerimaan.pokok_0), 0) AS pokok_2019,
	nvl(sum(penerimaan.stts_tahun_1), 0) AS stts_tahun_2018,
	--        nvl(sum(penerimaan.jum_tahun_1), 0)  as jum_tahun_1,
	--        nvl(sum(penerimaan.denda_1), 0)      as denda_1,
 nvl(sum(penerimaan.pokok_1), 0) AS pokok_2018,
	nvl(sum(penerimaan.stts_tahun_2), 0) AS stts_tahun_2017,
	--        nvl(sum(penerimaan.jum_tahun_2), 0)  as jum_tahun_2,
	--        nvl(sum(penerimaan.denda_2), 0)      as denda_2,
 nvl(sum(penerimaan.pokok_2), 0) AS pokok_2017,
	nvl(sum(penerimaan.stts_tahun_3), 0) AS stts_tahun_2016,
	--        nvl(sum(penerimaan.jum_tahun_3), 0)  as jum_tahun_3,
	--        nvl(sum(penerimaan.denda_3), 0)      as denda_3,
 nvl(sum(penerimaan.pokok_3), 0) AS pokok_2016,
	nvl(sum(penerimaan.stts_tahun_4), 0) AS stts_tahun_2015,
	--        nvl(sum(penerimaan.jum_tahun_4), 0)  as jum_tahun_4,
	--        nvl(sum(penerimaan.denda_4), 0)      as denda_4,
 nvl(sum(penerimaan.pokok_4), 0) AS pokok_2015,
	nvl(sum(penerimaan.stts_tahun_5), 0) AS stts_tahun_2014,
	--        nvl(sum(penerimaan.jum_tahun_5), 0)  as jum_tahun_5,
	--        nvl(sum(penerimaan.denda_5), 0)      as denda_5,
 nvl(sum(penerimaan.pokok_5), 0) AS pokok_2014,
	nvl(sum(penerimaan.stts_tahun_6), 0) AS stts_tahun_2013,
	--        nvl(sum(penerimaan.jum_tahun_6), 0)  as jum_tahun_6,
	--        nvl(sum(penerimaan.denda_6), 0)      as denda_6,
 nvl(sum(penerimaan.pokok_6), 0) AS pokok_2013,
	nvl(sum(penerimaan.stts_all), 0) AS stts_tahun_all,
	--        nvl(sum(penerimaan.jum_all), 0)      as jum_tahun_all,
	--               nvl(sum(penerimaan.denda_all), 0)    as denda_tahun_all,
 nvl(sum(penerimaan.pokok_all), 0) AS pokok_tahun_all
FROM
	(
	SELECT
		*
	FROM
		ref_kelurahan
	WHERE
		kd_kecamatan = '$(kec)') kel
LEFT JOIN (
	SELECT
		*
	FROM
		(
		SELECT
			KD_PROPINSI,
			KD_DATI2,
			KD_KECAMATAN,
			KD_KELURAHAN,
			COUNT(*) AS STTS_ALL,
			SUM(JML_SPPT_YG_DIBAYAR) AS JUM_ALL,
			SUM(DENDA_SPPT) AS DENDA_ALL,
			SUM(JML_SPPT_YG_DIBAYAR - DENDA_SPPT) AS POKOK_ALL,
			TGL_BAYAR,
			(COUNT(DECODE(KATEGORI_TAHUN, 0, 1))) STTS_TAHUN_0,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 0, JML_SPPT_YG_DIBAYAR)), 0) JUM_TAHUN_0,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 0, DENDA_SPPT)), 0) DENDA_0,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 0, JML_SPPT_YG_DIBAYAR - DENDA_SPPT)), 0) POKOK_0,
			(COUNT(DECODE(KATEGORI_TAHUN, 1, 1))) STTS_TAHUN_1,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 1, JML_SPPT_YG_DIBAYAR)), 0) JUM_TAHUN_1,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 1, DENDA_SPPT)), 0) DENDA_1,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 1, JML_SPPT_YG_DIBAYAR - DENDA_SPPT)), 0) POKOK_1,
			(COUNT(DECODE(KATEGORI_TAHUN, 2, 1))) STTS_TAHUN_2,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 2, JML_SPPT_YG_DIBAYAR)), 0) JUM_TAHUN_2,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 2, DENDA_SPPT)), 0) DENDA_2,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 2, JML_SPPT_YG_DIBAYAR - DENDA_SPPT)), 0) POKOK_2,
			(COUNT(DECODE(KATEGORI_TAHUN, 3, 1))) STTS_TAHUN_3,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 3, JML_SPPT_YG_DIBAYAR)), 0) JUM_TAHUN_3,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 3, DENDA_SPPT)), 0) DENDA_3,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 3, JML_SPPT_YG_DIBAYAR - DENDA_SPPT)), 0) POKOK_3,
			(COUNT(DECODE(KATEGORI_TAHUN, 4, 1))) STTS_TAHUN_4,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 4, JML_SPPT_YG_DIBAYAR)), 0) JUM_TAHUN_4,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 4, DENDA_SPPT)), 0) DENDA_4,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 4, JML_SPPT_YG_DIBAYAR - DENDA_SPPT)), 0) POKOK_4,
			(COUNT(DECODE(KATEGORI_TAHUN, 5, 1))) STTS_TAHUN_5,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 5, JML_SPPT_YG_DIBAYAR)), 0) JUM_TAHUN_5,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 5, DENDA_SPPT)), 0) DENDA_5,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 5, JML_SPPT_YG_DIBAYAR - DENDA_SPPT)), 0) POKOK_5,
			(COUNT(DECODE(KATEGORI_TAHUN, 6, 1))) STTS_TAHUN_6,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 6, JML_SPPT_YG_DIBAYAR)), 0) JUM_TAHUN_6,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 6, DENDA_SPPT)), 0) DENDA_6,
			NVL(SUM(DECODE(KATEGORI_TAHUN, 6, JML_SPPT_YG_DIBAYAR - DENDA_SPPT)), 0) POKOK_6
		FROM
			(
			SELECT
				KD_PROPINSI,
				KD_DATI2,
				KD_KECAMATAN,
				KD_KELURAHAN,
				KD_BLOK,
				NO_URUT,
				KD_JNS_OP,
				THN_PAJAK_SPPT,
				PEMBAYARAN_SPPT_KE,
				JML_SPPT_YG_DIBAYAR,
				DENDA_SPPT,
				TRUNC(TGL_PEMBAYARAN_SPPT) AS TGL_BAYAR,
			CASE
					WHEN THN_PAJAK_SPPT = $(thn) THEN '0'
					WHEN THN_PAJAK_SPPT = $(thn) - 1 THEN '1'
					WHEN THN_PAJAK_SPPT = $(thn) - 2 THEN '2'
					WHEN THN_PAJAK_SPPT = $(thn) - 3 THEN '3'
					WHEN THN_PAJAK_SPPT = $(thn) - 4 THEN '4'
					WHEN THN_PAJAK_SPPT = $(thn) - 5 THEN '5'
					ELSE '6'
				END AS KATEGORI_TAHUN
			FROM
				pembayaran_sppt
			WHERE
				thn_pajak_sppt <= 2019) pembayaran
		GROUP BY
			KD_PROPINSI,
			KD_DATI2,
			KD_KECAMATAN,
			KD_KELURAHAN,
			TGL_BAYAR) view_terima_detail_kel
	WHERE
		trunc(tgl_bayar) BETWEEN to_date('$(tgl_awal)', 'DD/MM/YYYY') AND to_date('$(tgl_akhir)', 'DD/MM/YYYY')) penerimaan ON
	kel.kd_propinsi = penerimaan.kd_propinsi
	AND kel.kd_dati2 = penerimaan.kd_dati2
	AND kel.kd_kecamatan = penerimaan.kd_kecamatan
	AND kel.kd_kelurahan = penerimaan.kd_kelurahan
GROUP BY
	kel.kd_kelurahan,
	kel.nm_kelurahan
ORDER BY
	kel.KD_KELURAHAN ASC;
-- TODO summary penerimaan
 SELECT
	kel.kd_kelurahan,
	kel.nm_kelurahan,
	nvl(sum(penerimaan.stts), 0) AS stts,
	nvl(sum(penerimaan.pokok), 0) AS pokok,
	nvl(sum(penerimaan.denda), 0) AS denda,
	nvl(sum(penerimaan.jumlah), 0) AS jumlah
FROM
	(
	SELECT
		*
	FROM
		ref_kelurahan
	WHERE
		kd_kecamatan = '100') kel
LEFT JOIN (
	SELECT
		*
	FROM
		(
		SELECT
			kd_propinsi,
			kd_dati2,
			kd_kecamatan,
			kd_kelurahan,
			TRUNC(tgl_pembayaran_sppt) AS tanggal,
			COUNT(*) AS stts,
			SUM(jml_sppt_yg_dibayar - denda_sppt) AS pokok,
			SUM(denda_sppt) AS denda,
			SUM(jml_sppt_yg_dibayar) AS jumlah
		FROM
			pembayaran_sppt
		WHERE
			thn_pajak_sppt <= 2019
		GROUP BY
			kd_propinsi,
			kd_dati2,
			kd_kecamatan,
			kd_kelurahan,
			TRUNC(tgl_pembayaran_sppt)) view_penerimaan_kel
	WHERE
		trunc(tanggal) BETWEEN to_date('01/01/2019', 'DD/MM/YYYY') AND to_date('31/08/2019', 'DD/MM/YYYY')) penerimaan ON
	kel.kd_propinsi = penerimaan.kd_propinsi
	AND kel.kd_dati2 = penerimaan.kd_dati2
	AND kel.kd_kecamatan = penerimaan.kd_kecamatan
	AND kel.kd_kelurahan = penerimaan.kd_kelurahan
GROUP BY
	kel.kd_kelurahan,
	kel.nm_kelurahan
ORDER BY
	kel.KD_KELURAHAN ASC;
-- bandingkan SPPT dan SPPT_Existing dari server
 SELECT
	count(*),
	'sppt' AS keterangan
FROM
	sppt
UNION
SELECT
	count(*),
	'sppt_existing' AS keterangan
FROM
	SPPT_EXISTING;

TRUNCATE
	TABLE SPPT_EXISTING;
-- TODO update buka blokir dibagi per kecamatan atau kelurahan
 UPDATE
	DAT_OBJEK_PAJAK a
SET
	a.KD_JNS_OP = 0
	-- select count(*)
	-- from DAT_OBJEK_PAJAK a

	WHERE a.KD_JNS_OP = 9
	AND a.KD_KECAMATAN = 090;
-- TODO cari NOP duplikat
-- KD_KECAMATAN=070 and KD_KELURAHAN=001 and KD_BLOK=011 and NO_URUT=0064 jadi 0180

-- KD_KECAMATAN=080 and KD_KELURAHAN=003 and KD_BLOK=017 and NO_URUT=0030 jadi 0207
 SELECT
	a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT AS NOP,
	count(a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT)
FROM
	DAT_OBJEK_PAJAK a
GROUP BY
	a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT
HAVING
	count (a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT) > 1;

SELECT
	count(*)
FROM
	DAT_OBJEK_PAJAK a
	-- update DAT_OBJEK_PAJAK a set a.KD_JNS_OP = 0

	WHERE a.KD_JNS_OP = 9;
-- insert into SPPT(KD_PROPINSI, KD_DATI2, KD_KECAMATAN, KD_KELURAHAN, KD_BLOK, NO_URUT, KD_JNS_OP, THN_PAJAK_SPPT, SIKLUS_SPPT, KD_KANWIL_BANK, KD_KPPBB_BANK, KD_BANK_TUNGGAL, KD_BANK_PERSEPSI, KD_TP, NM_WP_SPPT, JLN_WP_SPPT, BLOK_KAV_NO_WP_SPPT, RW_WP_SPPT, RT_WP_SPPT, KELURAHAN_WP_SPPT, KOTA_WP_SPPT, KD_POS_WP_SPPT, NPWP_SPPT, NO_PERSIL_SPPT, KD_KLS_TANAH, THN_AWAL_KLS_TANAH, KD_KLS_BNG, THN_AWAL_KLS_BNG, TGL_JATUH_TEMPO_SPPT, LUAS_BUMI_SPPT, LUAS_BNG_SPPT, NJOP_BUMI_SPPT, NJOP_BNG_SPPT, NJOP_SPPT, NJOPTKP_SPPT, NJKP_SPPT, PBB_TERHUTANG_SPPT, FAKTOR_PENGURANG_SPPT, PBB_YG_HARUS_DIBAYAR_SPPT, STATUS_PEMBAYARAN_SPPT, STATUS_TAGIHAN_SPPT, STATUS_CETAK_SPPT, TGL_TERBIT_SPPT, TGL_CETAK_SPPT, NIP_PENCETAK_SPPT, JENIS_BAYAR, TGL_PEMBAYARAN_SPPT, STATUS_SINKRONISASI, TANGGAL_SINKRONISASI, STATUS_DAFNOM_PIUTANG)
-- select KD_PROPINSI,
--        KD_DATI2,
--        KD_KECAMATAN,
--        KD_KELURAHAN,
--        KD_BLOK,
--        NO_URUT,
--        KD_JNS_OP,
--        THN_PAJAK_SPPT,
--        SIKLUS_SPPT,
--        KD_KANWIL_BANK,
--        KD_KPPBB_BANK,
--        KD_BANK_TUNGGAL,
--        KD_BANK_PERSEPSI,
--        KD_TP,
--        NM_WP_SPPT,
--        JLN_WP_SPPT,
--        BLOK_KAV_NO_WP_SPPT,
--        RW_WP_SPPT,
--        RT_WP_SPPT,
--        KELURAHAN_WP_SPPT,
--        KOTA_WP_SPPT,
--        KD_POS_WP_SPPT,
--        NPWP_SPPT,
--        NO_PERSIL_SPPT,
--        KD_KLS_TANAH,
--        THN_AWAL_KLS_TANAH,
--        KD_KLS_BNG,
--        THN_AWAL_KLS_BNG,
--        TGL_JATUH_TEMPO_SPPT,
--        LUAS_BUMI_SPPT,
--        LUAS_BNG_SPPT,
--        NJOP_BUMI_SPPT,
--        NJOP_BNG_SPPT,
--        NJOP_SPPT,
--        NJOPTKP_SPPT,
--        NJKP_SPPT,
--        PBB_TERHUTANG_SPPT,
--        FAKTOR_PENGURANG_SPPT,
--        PBB_YG_HARUS_DIBAYAR_SPPT,
--        STATUS_PEMBAYARAN_SPPT,
--        STATUS_TAGIHAN_SPPT,
--        STATUS_CETAK_SPPT,
--        TGL_TERBIT_SPPT,
--        TGL_CETAK_SPPT,
--        NIP_PENCETAK_SPPT,
--        JENIS_BAYAR,
--        TGL_PEMBAYARAN_SPPT,
--        STATUS_SINKRONISASI,
--        TANGGAL_SINKRONISASI,

--        STATUS_DAFNOM_PIUTANG
 SELECT
	count(*)
FROM
	SPPT_EXISTING a
WHERE
	NOT EXISTS(
	SELECT
		*
	FROM
		SPPT b
	WHERE
		a.KD_KECAMATAN = b.KD_KECAMATAN
		AND a.KD_KELURAHAN = b.KD_KELURAHAN
		AND a.KD_BLOK = b.KD_BLOK
		AND a.NO_URUT = b.NO_URUT
		--           and a.KD_JNS_OP = b.KD_JNS_OP
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT );

UPDATE
	sppt a
SET
	a.KD_JNS_OP = 0
WHERE
	a.KD_JNS_OP;

SELECT
	count(*)
FROM
	sppt a
WHERE
	a.THN_PAJAK_SPPT = 2019;

SELECT
	count(*),
	'vm' AS keterangan
FROM
	SPPT a
	-- where a.KD_KECAMATAN = '$(kec)'

	WHERE a.THN_PAJAK_SPPT BETWEEN '$(thnawal)' AND '$(thnakhir)';
--TODO UPDATE status bayar yang sudah ada di TABLE pembayaran
 UPDATE
	sppt s
SET
	s.STATUS_PEMBAYARAN_SPPT = 1
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 0
	AND EXISTS (
	SELECT
		*
	FROM
		PEMBAYARAN_SPPT ps
	WHERE
		s.KD_KECAMATAN = ps.KD_KECAMATAN
		AND s.KD_KELURAHAN = ps.KD_KELURAHAN
		AND s.KD_BLOK = ps.KD_BLOK
		AND s.NO_URUT = ps.NO_URUT
		AND s.THN_PAJAK_SPPT = ps.THN_PAJAK_SPPT );

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	SPPT s
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.THN_PAJAK_SPPT BETWEEN '1994' AND '2013'
	AND STATUS_DAFNOM_PIUTANG IN(1,
	11);

SELECT
	count(s.KD_PROPINSI),
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	SPPT s
WHERE
	s.THN_PAJAK_SPPT = 2019;
--TODO ambil NOP dari monitoring-tunggakan
 SELECT
	*
FROM
	view_sppt_op_dimas
WHERE
	kd_kecamatan = :kd_kec
	--	AND KD_KELURAHAN = :kd_kel
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
	--	AND KD_KELURAHAN = :kd_kel
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
		--		AND KD_KELURAHAN = :kd_kel
		-- 				and thn_pajak_sppt='$(tahun)'
		AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
		AND TGL_PEMBAYARAN_SPPT > TO_DATE(:tgl_akhir, 'DD/MM/YYYY') );

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT),
	count(s.KD_PROPINSI)
FROM
	SPPT s
WHERE
	s.KD_KECAMATAN = 031
	AND s.THN_PAJAK_SPPT = 2019;
--query limit
 SELECT
	*
FROM
	(
	SELECT
		*
	FROM
		SPPT s
	WHERE
		s.THN_PAJAK_SPPT = 2019 )
WHERE
	rownum <= 10;
--UPDATE
--	SPPT s
--SET

--	s.STATUS_PEMBAYARAN_SPPT = 0
 SELECT
	count(ps.KD_PROPINSI)
	--delete

	FROM PEMBAYARAN_SPPT ps
WHERE
	ps.THN_PAJAK_SPPT IN ('2019',
	'2020');

SELECT
	count(*)
FROM
	SPPT ss
WHERE
	ss.THN_PAJAK_SPPT IN ('2019',
	'2020')
	AND ss.KD_KECAMATAN = 080
	AND ss.KD_KELURAHAN = 001
	AND ss.STATUS_PEMBAYARAN_SPPT = 1;

SELECT
	'35-12' || '-' || s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '-0' AS NOP,
	s.PBB_YG_HARUS_DIBAYAR_SPPT + 5000 AS "plus 5000",
	s.PBB_YG_HARUS_DIBAYAR_SPPT AS ketetapan
FROM
	SPPT s
WHERE
	s.KD_KECAMATAN = 080
	AND s.KD_KELURAHAN = 001
	AND s.THN_PAJAK_SPPT = 2019
	AND s.STATUS_DAFNOM_PIUTANG = 11;

UPDATE
	SPPT s
SET
	s.PBB_YG_HARUS_DIBAYAR_SPPT = s.PBB_YG_HARUS_DIBAYAR_SPPT + 5000
WHERE
	s.KD_KECAMATAN = 080
	AND s.KD_KELURAHAN = 001
	AND KD_BLOK = 019
	AND NO_URUT IN ('0022')
	AND THN_PAJAK_SPPT = 2019;
--cari yang di sppt tidka sama dengan di pembayaran_sppt
 SELECT
	'35-12' || '-' || s2.KD_KECAMATAN || '-' || s2.KD_KELURAHAN || '-' || s2.KD_BLOK || '-' || s2.NO_URUT || '-0' AS NOP,
	s2.PBB_TERHUTANG_SPPT AS sppt_terhutang,
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
ORDER BY
	STATUS ASC;

SELECT
	'35-12' || '-' || s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '-0' AS NOP,
	s.PBB_YG_HARUS_DIBAYAR_SPPT AS sppt,
	s.PBB_TERHUTANG_SPPT AS terhutang
FROM
	SPPT s
WHERE
	s.PBB_YG_HARUS_DIBAYAR_SPPT = (s.PBB_TERHUTANG_SPPT-5000)
	AND s.THN_PAJAK_SPPT = 2019;

SELECT
	*
FROM
	PEMBAYARAN_SPPT ps
WHERE
	ps.PEMBAYARAN_SPPT_KE >1
	AND ps.THN_PAJAK_SPPT = 2019;

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	SPPT s
WHERE
	s.THN_PAJAK_SPPT = 2019
	AND s.KD_KECAMATAN = 080
	AND s.KD_KELURAHAN = 001;

SELECT
	sum(ps.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	SPPT ps
WHERE
	ps.THN_PAJAK_SPPT = 2020;

SELECT
	sum(ps.JML_SPPT_YG_DIBAYAR - ps.DENDA_SPPT) AS "total_2020"
FROM
	PEMBAYARAN_SPPT ps
WHERE
	ps.TGL_PEMBAYARAN_SPPT >= to_date('2020-01-01', 'yyyy-mm-dd')
	AND ps.TGL_PEMBAYARAN_SPPT <= to_date('2020-12-31', 'yyyy-mm-dd')
	AND ps.THN_PAJAK_SPPT = 2020;

SELECT
	sum(ps.JML_SPPT_YG_DIBAYAR - ps.DENDA_SPPT) AS "total=2019"
FROM
	PEMBAYARAN_SPPT ps
WHERE
	ps.TGL_PEMBAYARAN_SPPT >= to_date('2020-01-01', 'yyyy-mm-dd')
	AND ps.TGL_PEMBAYARAN_SPPT <= to_date('2020-12-31', 'yyyy-mm-dd')
	AND ps.THN_PAJAK_SPPT = 2019;

SELECT
	sum(ps.JML_SPPT_YG_DIBAYAR - ps.DENDA_SPPT) AS "total<2019"
FROM
	PEMBAYARAN_SPPT ps
WHERE
	ps.TGL_PEMBAYARAN_SPPT >= to_date('2020-01-01', 'yyyy-mm-dd')
	AND ps.TGL_PEMBAYARAN_SPPT <= to_date('2020-12-31', 'yyyy-mm-dd')
	AND ps.THN_PAJAK_SPPT BETWEEN 2014 AND 2018;

SELECT
	sum(ps.JML_SPPT_YG_DIBAYAR - ps.DENDA_SPPT) AS "total"
FROM
	PEMBAYARAN_SPPT ps
WHERE
	ps.TGL_PEMBAYARAN_SPPT >= to_date('2020-01-01', 'yyyy-mm-dd')
	AND ps.TGL_PEMBAYARAN_SPPT <= to_date('2020-12-31', 'yyyy-mm-dd');

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nominal,
	count(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS sppt
FROM
	SPPT s
WHERE
	s.THN_PAJAK_SPPT = 2019;

SELECT
	count(*)
	--delete

	FROM PEMBAYARAN_SPPT ps
WHERE
	ps.TGL_PEMBAYARAN_SPPT >= to_date('2020-01-01', 'yyyy-mm-dd')
	AND ps.TGL_PEMBAYARAN_SPPT <= to_date('2020-12-31', 'yyyy-mm-dd')
	AND ps.THN_PAJAK_SPPT < 2019;

SELECT
	*
FROM
	SPPT s
	--WHERE s.KD_KECAMATAN =070 AND KD_KELURAHAN =003 AND s.PBB_YG_HARUS_DIBAYAR_SPPT =39272 AND THN_PAJAK_SPPT =2019 AND s.STATUS_PEMBAYARAN_SPPT =;

	WHERE s.PBB_YG_HARUS_DIBAYAR_SPPT = 39272
	AND THN_PAJAK_SPPT = 2019
	AND s.STATUS_PEMBAYARAN_SPPT = 0;

SELECT
	*
FROM
	SPPT s
WHERE
	s.PBB_YG_HARUS_DIBAYAR_SPPT = 39272
	AND s.THN_PAJAK_SPPT = 2019;

SELECT
	*
FROM
	PEMBAYARAN_SPPT ps
WHERE
	ps.KD_KECAMATAN = 150
	AND ps.KD_KELURAHAN = 002
	AND ps.KD_BLOK = 028
	AND ps.NO_URUT = 0012;
--35-12-150-002-028-0012-0 
 SELECT
	*
FROM
	SPPT s2
WHERE
	s2.KD_KECAMATAN = 140
	AND s2.KD_KELURAHAN = 002
	AND s2.THN_PAJAK_SPPT = 2019
	AND s2.PBB_TERHUTANG_SPPT = s2.PBB_YG_HARUS_DIBAYAR_SPPT + 119;

SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nominal,
	count(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS sppt
FROM
	SPPT s
	--WHERE s.THN_PAJAK_SPPT =2019 AND s.KD_KECAMATAN = :kec AND s.KD_KELURAHAN  = :kel;

	WHERE s.THN_PAJAK_SPPT = 2019
	AND s.KD_KECAMATAN = :kec ;

SELECT
	sum(ps.JML_SPPT_YG_DIBAYAR-ps.DENDA_SPPT) AS pokok
	--DELETE 

	FROM PEMBAYARAN_SPPT ps
WHERE
	ps.TGL_PEMBAYARAN_SPPT >= to_date('2020-01-01', 'yyyy-mm-dd')
	AND ps.TGL_PEMBAYARAN_SPPT <= to_date('2020-12-31', 'yyyy-mm-dd')
	AND ps.KD_KECAMATAN = '031';
--TODO flag pembayaran_sppt yang tgl bayar nya diatas 01-01-2020

--SELECT *
 UPDATE
	PEMBAYARAN_SPPT
SET
	JENIS_BAYAR = NULL
	--FROM PEMBAYARAN_SPPT ps 

	WHERE TGL_PEMBAYARAN_SPPT > to_date('2020-01-01', 'yyyy-mm-dd')
	AND JENIS_BAYAR = 0;
--TODO cari nominal sppt yang tidak sama dengan yg dibayar di pembayaran_sppt
 SELECT
	'35-12' || '-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-0' AS NOP,
	a.PBB_YG_HARUS_DIBAYAR_SPPT AS nominal_sppt,
	b.JML_SPPT_YG_DIBAYAR - b.DENDA_SPPT AS nominal_ps,
	a.THN_PAJAK_SPPT AS tahun,
	b.TGL_PEMBAYARAN_SPPT AS tgl_bayar
FROM
	SPPT a
LEFT JOIN pembayaran_sppt b ON
	a.KD_KECAMATAN = b.KD_KECAMATAN
	AND a.KD_KELURAHAN = b.KD_KELURAHAN
	AND a.KD_BLOK = b.KD_BLOK
	AND a.NO_URUT = b.NO_URUT
	AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
	--WHERE a.KD_KECAMATAN ='031' AND a.STATUS_PEMBAYARAN_SPPT = 1 AND a.PBB_YG_HARUS_DIBAYAR_SPPT != b.JML_SPPT_YG_DIBAYAR - b.DENDA_SPPT ;

	WHERE a.STATUS_PEMBAYARAN_SPPT = 1
	AND a.PBB_YG_HARUS_DIBAYAR_SPPT != b.JML_SPPT_YG_DIBAYAR - b.DENDA_SPPT
	AND b.PEMBAYARAN_SPPT_KE = 1
	AND b.KD_KECAMATAN = 020;
--TODO hitung 2019 di local

--DELETE 
 SELECT
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM
	SPPT s
WHERE
	s.THN_PAJAK_SPPT = 2020
	AND s.KD_KECAMATAN = 031;
--TODO cari yang nominal tidak antara pembayaran dan nominal sppt
 SELECT
	'35-12' || '-' || s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '-0' AS NOP,
	s.THN_PAJAK_SPPT AS thn,
	s.PBB_YG_HARUS_DIBAYAR_SPPT AS yg_harus_dby,
	s.PBB_TERHUTANG_SPPT AS pbb_tht,
	(ps.JML_SPPT_YG_DIBAYAR-ps.DENDA_SPPT) AS nominal_pokok_bayar
FROM
	sppt s
LEFT JOIN PEMBAYARAN_SPPT ps ON
	s.KD_KECAMATAN = ps.KD_KECAMATAN
	AND s.KD_KELURAHAN = ps.KD_KELURAHAN
	AND s.KD_BLOK = ps.KD_BLOK
	AND s.NO_URUT = ps.NO_URUT
	AND s.THN_PAJAK_SPPT = ps.THN_PAJAK_SPPT
WHERE
	ps.TGL_PEMBAYARAN_SPPT >= to_date('2020-01-01', 'yyyy-mm-dd')
	AND ps.TGL_PEMBAYARAN_SPPT <= to_date('2020-12-31', 'yyyy-mm-dd')
	AND s.PBB_YG_HARUS_DIBAYAR_SPPT != ps.JML_SPPT_YG_DIBAYAR- ps.DENDA_SPPT ;

--TODO ambil records detail menu monitoring-piutang
 SELECT
	*
FROM
	view_sppt_op_dimas
WHERE
	kd_kecamatan = :kd_kec
	AND KD_KELURAHAN = :kd_kel
	AND status_pembayaran_sppt = 0
	AND status_dafnom_piutang IN ('1',
	'11')
	AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
UNION
SELECT
	*
FROM
	view_sppt_op_dimas
WHERE
	kd_kecamatan = :kd_kec
	AND KD_KELURAHAN = :kd_kel
	AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
	--                    and status_dafnom_piutang in ('1', '11') -- tambahan
	AND KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT IN (
	SELECT
		KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT
	FROM
		PEMBAYARAN_SPPT
	WHERE
		kd_kecamatan = :kd_kec
		AND KD_KELURAHAN = :kd_kel
		AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
		AND TGL_PEMBAYARAN_SPPT > TO_DATE(:tgl_akhir, 'DD/MM/YYYY') );

UPDATE PBB.SPPT SET SIKLUS_SPPT=1, KD_KANWIL_BANK='12', KD_KPPBB_BANK='10', KD_BANK_TUNGGAL='02', KD_BANK_PERSEPSI='12', KD_TP='23', NM_WP_SPPT='NA. P / DRUBI', JLN_WP_SPPT='KP. KRAJAN', BLOK_KAV_NO_WP_SPPT=NULL, RW_WP_SPPT=NULL, RT_WP_SPPT=NULL, KELURAHAN_WP_SPPT='LUBAWANG KIDUL', KOTA_WP_SPPT='SITUBONDO', KD_POS_WP_SPPT=NULL, NPWP_SPPT='-', NO_PERSIL_SPPT=NULL, KD_KLS_TANAH='A35', THN_AWAL_KLS_TANAH='1999', KD_KLS_BNG='XXX', THN_AWAL_KLS_BNG='1986', TGL_JATUH_TEMPO_SPPT=TIMESTAMP '2009-08-31 00:00:00.000000', LUAS_BUMI_SPPT=1530, LUAS_BNG_SPPT=0, NJOP_BUMI_SPPT=30600000, NJOP_BNG_SPPT=0, NJOP_SPPT=30600000, NJOPTKP_SPPT=0, NJKP_SPPT=20, PBB_TERHUTANG_SPPT=30600, FAKTOR_PENGURANG_SPPT=0, PBB_YG_HARUS_DIBAYAR_SPPT=30600, STATUS_PEMBAYARAN_SPPT='4', STATUS_TAGIHAN_SPPT='0', STATUS_CETAK_SPPT='1', TGL_TERBIT_SPPT=TIMESTAMP '2009-01-02 00:00:00.000000', TGL_CETAK_SPPT=TIMESTAMP '2009-01-14 15:32:08.000000', NIP_PENCETAK_SPPT='060000000', JENIS_BAYAR=NULL, TGL_PEMBAYARAN_SPPT=NULL, STATUS_SINKRONISASI=0, TANGGAL_SINKRONISASI=NULL, STATUS_DAFNOM_PIUTANG=0 WHERE KD_PROPINSI='35' AND KD_DATI2='12' AND KD_KECAMATAN='031' AND KD_KELURAHAN='005' AND KD_BLOK='003' AND NO_URUT='0081' AND KD_JNS_OP='0' AND THN_PAJAK_SPPT='2009';




SELECT
	s2.PBB_TERHUTANG_SPPT AS terhutang,
	s2.PBB_YG_HARUS_DIBAYAR_SPPT AS dibayar
FROM
	SPPT s2
WHERE
	s2.PBB_TERHUTANG_SPPT != s2.PBB_YG_HARUS_DIBAYAR_SPPT
	AND s2.THN_PAJAK_SPPT = 2014;
