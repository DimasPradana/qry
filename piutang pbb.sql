
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
			kd_kecamatan IN (:kd_kec)) kel
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
				kd_kecamatan in (:kd_kec)
--				AND KD_KELURAHAN = :kd_kel
				AND status_pembayaran_sppt IN (0,
				6)
				AND status_dafnom_piutang IN ('1',
				'11')
				AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
		UNION
			SELECT
				*
			FROM
				view_sppt_op_dimas
			WHERE
				kd_kecamatan in (:kd_kec)
--				AND KD_KELURAHAN = :kd_kel
				AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
				AND KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT IN (
				SELECT
					KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP || THN_PAJAK_SPPT
				FROM
					PEMBAYARAN_SPPT
				WHERE
					kd_kecamatan in (:kd_kec)
--					AND KD_KELURAHAN = :kd_kel
					AND thn_pajak_sppt BETWEEN :thnawal AND :thnakhir
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
	GROUP BY
		kel.kd_kelurahan,
		kel.nm_kelurahan
	ORDER BY
		kel.kd_kelurahan);
-- TODO cari nominal yang mendekati neraca samid_1
 SELECT
	s.KD_KECAMATAN,
	s.KD_KELURAHAN,
	s.KD_BLOK,
	s.NO_URUT,
	s.THN_PAJAK_SPPT,
	s.PBB_YG_HARUS_DIBAYAR_SPPT,
	s.STATUS_DAFNOM_PIUTANG AS stats_dafnom,
	s.STATUS_PEMBAYARAN_SPPT AS lunas
	--	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS total

	FROM sppt s
WHERE
	s.KD_KECAMATAN = :kec
	AND s.KD_KELURAHAN = :kel
	AND s.THN_PAJAK_SPPT BETWEEN :thnawal AND :thnakhir
	AND s.STATUS_PEMBAYARAN_SPPT = 0
	AND s.STATUS_DAFNOM_PIUTANG IN (1,
	11)
GROUP BY
	s.KD_KECAMATAN,
	s.KD_KELURAHAN,
	s.KD_BLOK,
	s.NO_URUT,
	s.THN_PAJAK_SPPT,
	s.PBB_YG_HARUS_DIBAYAR_SPPT,
	s.STATUS_DAFNOM_PIUTANG,
	s.STATUS_PEMBAYARAN_SPPT
HAVING
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) > :btsmax
ORDER BY
	total DESC;
--TODO ambil NOP nya dari monitoring-tunggakan samid_3
 SELECT
	*
FROM
	view_sppt_op_dimas
WHERE
	kd_kecamatan = :kd_kec
	AND KD_KELURAHAN = :kd_kel
	AND status_pembayaran_sppt IN (0,
	6)
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
--UPDATE SPPT s

--SET s.STATUS_PEMBAYARAN_SPPT =5
 SELECT
	count(s.KD_PROPINSI) AS sppt,
	sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) AS nominal
	--SELECT *

	FROM SPPT s
WHERE
	s.KD_KECAMATAN = 030
	AND s.KD_KELURAHAN = 011
	AND s.STATUS_DAFNOM_PIUTANG IN (1,
	11)
	AND s.STATUS_PEMBAYARAN_SPPT IN (0,
	6)
	--	AND s.KD_BLOK BETWEEN '005' AND '005'
	--	AND s.NO_URUT BETWEEN '0001' AND '0051'
	AND s.THN_PAJAK_SPPT BETWEEN '2020' AND '2020';

SELECT
	*
FROM
	PEMBAYARAN_SPPT p
LEFT JOIN SPPT s ON
	s.KD_PROPINSI = p.KD_PROPINSI
	AND s.KD_DATI2 = p.KD_DATI2
	AND s.KD_KECAMATAN = p.KD_KECAMATAN
	AND s.KD_KELURAHAN = p.KD_KELURAHAN
	AND s.KD_BLOK = p. KD_BLOK
	AND s.NO_URUT = p.NO_URUT
	AND s.KD_JNS_OP = p.KD_JNS_OP
	AND s.THN_PAJAK_SPPT = p.THN_PAJAK_SPPT
WHERE
	s.STATUS_PEMBAYARAN_SPPT = 0
	AND
	--      s.KD_KECAMATAN = 030 and
	--      s.KD_KELURAHAN = 011 and
 p.THN_PAJAK_SPPT = 2020
	AND p.TGL_PEMBAYARAN_SPPT BETWEEN to_date('2020-01-01', 'yyyy-mm-dd') AND to_date('2020-12-31', 'yyyy-mm-dd');

SELECT
	s.KD_KECAMATAN ,
	s.KD_KELURAHAN ,
	s.KD_BLOK ,
	s.NO_URUT ,
	s.THN_PAJAK_SPPT ,
	s.PBB_YG_HARUS_DIBAYAR_SPPT ,
	s.STATUS_PEMBAYARAN_SPPT ,
	ps.JML_SPPT_YG_DIBAYAR -ps.DENDA_SPPT AS pokok,
	ps.THN_PAJAK_SPPT AS thn_pajak_ps
FROM
	SPPT s
LEFT JOIN PEMBAYARAN_SPPT ps ON
	ps.KD_KECAMATAN = s.KD_KECAMATAN
	AND ps.KD_KELURAHAN = s.KD_KELURAHAN
	AND ps.KD_BLOK = s.KD_BLOK
	AND ps.NO_URUT = s.NO_URUT
	AND s.THN_PAJAK_SPPT = ps.THN_PAJAK_SPPT
WHERE
	s.PBB_YG_HARUS_DIBAYAR_SPPT != (ps.JML_SPPT_YG_DIBAYAR-ps.DENDA_SPPT)
	AND s.THN_PAJAK_SPPT = 2020;

SELECT
	dop.KD_KECAMATAN ,
	dop.KD_KELURAHAN ,
	dop.KD_BLOK ,
	dop.NO_URUT ,
	TOTAL_LUAS_BUMI
FROM
	DAT_OBJEK_PAJAK dop
	--LEFT JOIN DAT_OP_BUMI dob ON dop.KD_KECAMATAN =dob.KD_KECAMATAN AND dop.KD_KELURAHAN =dob.KD_KELURAHAN AND dop.KD_BLOK =dob.KD_BLOK AND dop.NO_URUT =dob.NO_URUT 

	WHERE dop.TOTAL_LUAS_BUMI <= 0;

UPDATE
	DAT_OBJEK_PAJAK dop
SET
	dop.KD_JNS_OP = 9
	--SELECT count(*)
	--FROM DAT_OBJEK_PAJAK dop

	WHERE dop.TOTAL_LUAS_BUMI <= 0;
	

SELECT sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
FROM SPPT s
WHERE s.THN_PAJAK_SPPT =2020;


--UPDATE SPPT s
--SET s.STATUS_PEMBAYARAN_SPPT = 1
--WHERE s.STATUS_PEMBAYARAN_SPPT IN (3,4,5);



SELECT sum(ps.JML_SPPT_YG_DIBAYAR-ps.DENDA_SPPT) AS nominal, count(*) AS stts
FROM PEMBAYARAN_SPPT ps 
WHERE ps.TGL_PEMBAYARAN_SPPT BETWEEN TO_DATE('2020-01-01','yyyy-mm-dd') AND TO_DATE('2020-12-31','yyyy-mm-dd');
--AND ps.THN_PAJAK_SPPT =2019;


--UPDATE DAT_OBJEK_PAJAK dop
--SET dop.KD_JNS_OP =9
--WHERE dop.KD_KECAMATAN =070 AND dop.KD_KELURAHAN =001 AND dop.KD_JNS_OP =0 AND dop.TOTAL_LUAS_BUMI <=0; 

--TODO cari yg statusnya belum lunas tapi ada di table pembayaran
-- UPDATE
--	sppt a
--SET
--	a.STATUS_PEMBAYARAN_SPPT = 0
select sum(a.PBB_YG_HARUS_DIBAYAR_SPPT)
from sppt a
	WHERE a.STATUS_PEMBAYARAN_SPPT = 1
	AND a.THN_PAJAK_SPPT =2019
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
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT);

	
--SELECT a.KD_KECAMATAN ||'-'||a.KD_KELURAHAN ||'-'||a.KD_BLOK ||'-'||a.NO_URUT ||'-0' AS nop,
--a.PBB_TERHUTANG_SPPT AS terhutang, a.PBB_YG_HARUS_DIBAYAR_SPPT AS tagihan, a.STATUS_PEMBAYARAN_SPPT AS status, a.NM_WP_SPPT AS nama
SELECT count(*)
from sppt a
--UPDATE SPPT a
--SET a.PBB_YG_HARUS_DIBAYAR_SPPT = a.PBB_YG_HARUS_DIBAYAR_SPPT +5000
	WHERE a.STATUS_PEMBAYARAN_SPPT in (0,1)
	AND a.THN_PAJAK_SPPT =2019
	AND a.PBB_TERHUTANG_SPPT != a.PBB_YG_HARUS_DIBAYAR_SPPT 
	AND a.PBB_YG_HARUS_DIBAYAR_SPPT = a.PBB_TERHUTANG_SPPT - 5000
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
		AND a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT);
	