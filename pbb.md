# QUERY PBB
 * ambil NOP dari WP yang melakukan pembayaran atau melakukan pelunasan dari tahun 2014 sampai 2018 (5 tahun)
```sql
select a.KD_PROPINSI,a.KD_DATI2,a.KD_KECAMATAN,a.KD_KELURAHAN,a.KD_BLOK,a.NO_URUT,a.KD_JNS_OP,
      a.KD_PROPINSI||'-'||a.KD_DATI2||'-'||a.KD_KECAMATAN||'-'||a.KD_KELURAHAN||'-'||a.KD_BLOK||'-'||a.NO_URUT||'-'||a.KD_JNS_OP as NOP
from SPPT a
left join PEMBAYARAN_SPPT b on
        a.KD_KECAMATAN = b.KD_KECAMATAN and
            a.KD_KELURAHAN = b.KD_KELURAHAN and
            a.KD_BLOK = b.KD_BLOK and
            a.NO_URUT = b.NO_URUT and
            a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
where b.THN_PAJAK_SPPT between '2014' and '2018'
group by a.KD_PROPINSI,a.KD_DATI2,a.KD_KECAMATAN,a.KD_KELURAHAN,a.KD_BLOK,a.NO_URUT,a.KD_JNS_OP
having count(*) = 5;
```

* ambil tagihan pbb tahun pajak 2018
```sql
select a.KD_PROPINSI||'-'||a.KD_DATI2||'-'||a.KD_KECAMATAN||'-'||a.KD_KELURAHAN||'-'||a.KD_BLOK||'-'||a.NO_URUT||'-'||a.KD_JNS_OP as NOP, a.PBB_YG_HARUS_DIBAYAR_SPPT
from sppt a
where a.THN_PAJAK_SPPT=2018;
```

* query menu monitoring - penerimaan pembayaran per wilayah
```sql
select
       (select count(*) from sppt where KD_PROPINSI=35 and KD_DATI2=12 and THN_PAJAK_SPPT=2018) as BAKU_WP,
       (select sum(PBB_YG_HARUS_DIBAYAR_SPPT) from sppt where KD_PROPINSI=35 and KD_DATI2=12 and THN_PAJAK_SPPT=2018) as BAKU_NOMINAL,
                    kel.KD_KECAMATAN,
                    kel.KD_KELURAHAN,
                    kel.nm_kelurahan,
                    nvl(sum(penerimaan.stts_tahun_0),0) as stts_tahun_0,
                    nvl(sum(penerimaan.jum_tahun_0),0) as jum_tahun_0,
                    nvl(sum(penerimaan.denda_0),0) as denda_0,
                    nvl(sum(penerimaan.pokok_0),0) as pokok_0,
                    nvl(sum(penerimaan.stts_tahun_1),0) as stts_tahun_1,
                    nvl(sum(penerimaan.jum_tahun_1),0) as jum_tahun_1,
                    nvl(sum(penerimaan.denda_1),0) as denda_1,
                    nvl(sum(penerimaan.pokok_1),0) as pokok_1,
                    nvl(sum(penerimaan.stts_tahun_2),0) as stts_tahun_2,
                    nvl(sum(penerimaan.jum_tahun_2),0) as jum_tahun_2,
					nvl(sum(penerimaan.denda_2),0) as denda_2,
					nvl(sum(penerimaan.pokok_2),0) as pokok_2,
                    nvl(sum(penerimaan.stts_tahun_3),0) as stts_tahun_3,
                    nvl(sum(penerimaan.jum_tahun_3),0) as jum_tahun_3,
					nvl(sum(penerimaan.denda_3),0) as denda_3,
					nvl(sum(penerimaan.pokok_3),0) as pokok_3,
                    nvl(sum(penerimaan.stts_tahun_4),0) as stts_tahun_4,
                    nvl(sum(penerimaan.jum_tahun_4),0) as jum_tahun_4,
					nvl(sum(penerimaan.denda_4),0) as denda_4,
					nvl(sum(penerimaan.pokok_4),0) as pokok_4,
                    nvl(sum(penerimaan.stts_tahun_5),0) as stts_tahun_5,
                    nvl(sum(penerimaan.jum_tahun_5),0) as jum_tahun_5,
					nvl(sum(penerimaan.denda_5),0) as denda_5,
					nvl(sum(penerimaan.pokok_5),0) as pokok_5,
                    nvl(sum(penerimaan.stts_tahun_6),0) as stts_tahun_6,
                    nvl(sum(penerimaan.jum_tahun_6),0) as jum_tahun_6,
					nvl(sum(penerimaan.denda_6),0) as denda_6,
					nvl(sum(penerimaan.pokok_6),0) as pokok_6,
                    nvl(sum(penerimaan.stts_all),0) as stts_tahun_all,
                    nvl(sum(penerimaan.jum_all),0) as jum_tahun_all,
                    nvl(sum(penerimaan.pokok_all),0) as pokok_tahun_all,
                    nvl(sum(penerimaan.denda_all),0) as denda_tahun_all
                    from (select * from ref_kelurahan ) kel left join
                    (select * from
                    (SELECT   KD_PROPINSI,
                      KD_DATI2,
                      KD_KECAMATAN,
                      KD_KELURAHAN,
                      COUNT ( * ) AS STTS_ALL,
                      SUM (JML_SPPT_YG_DIBAYAR) AS JUM_ALL,
                      SUM (DENDA_SPPT) AS DENDA_ALL,
                      SUM (JML_SPPT_YG_DIBAYAR - DENDA_SPPT) AS POKOK_ALL,
                      TGL_BAYAR,
                      (COUNT (DECODE (KATEGORI_TAHUN, 0, 1))) STTS_TAHUN_0,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 0, JML_SPPT_YG_DIBAYAR)), 0)
                         JUM_TAHUN_0,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 0, DENDA_SPPT)), 0) DENDA_0,
                      NVL (
                         SUM(DECODE (KATEGORI_TAHUN,
                                     0,
                                     JML_SPPT_YG_DIBAYAR - DENDA_SPPT)),
                         0
                      )
                         POKOK_0,
                      (COUNT (DECODE (KATEGORI_TAHUN, 1, 1))) STTS_TAHUN_1,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 1, JML_SPPT_YG_DIBAYAR)), 0)
                         JUM_TAHUN_1,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 1, DENDA_SPPT)), 0) DENDA_1,
                      NVL (
                         SUM(DECODE (KATEGORI_TAHUN,
                                     1,
                                     JML_SPPT_YG_DIBAYAR - DENDA_SPPT)),
                         0
                      )
                         POKOK_1,
                      (COUNT (DECODE (KATEGORI_TAHUN, 2, 1))) STTS_TAHUN_2,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 2, JML_SPPT_YG_DIBAYAR)), 0)
                         JUM_TAHUN_2,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 2, DENDA_SPPT)), 0) DENDA_2,
                      NVL (
                         SUM(DECODE (KATEGORI_TAHUN,
                                     2,
                                     JML_SPPT_YG_DIBAYAR - DENDA_SPPT)),
                         0
                      )
                         POKOK_2,
                      (COUNT (DECODE (KATEGORI_TAHUN, 3, 1))) STTS_TAHUN_3,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 3, JML_SPPT_YG_DIBAYAR)), 0)
                         JUM_TAHUN_3,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 3, DENDA_SPPT)), 0) DENDA_3,
                      NVL (
                         SUM(DECODE (KATEGORI_TAHUN,
                                     3,
                                     JML_SPPT_YG_DIBAYAR - DENDA_SPPT)),
                         0
                      )
                         POKOK_3,
                      (COUNT (DECODE (KATEGORI_TAHUN, 4, 1))) STTS_TAHUN_4,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 4, JML_SPPT_YG_DIBAYAR)), 0)
                         JUM_TAHUN_4,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 4, DENDA_SPPT)), 0) DENDA_4,
                      NVL (
                         SUM(DECODE (KATEGORI_TAHUN,
                                     4,
                                     JML_SPPT_YG_DIBAYAR - DENDA_SPPT)),
                         0
                      )
                         POKOK_4,
                      (COUNT (DECODE (KATEGORI_TAHUN, 5, 1))) STTS_TAHUN_5,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 5, JML_SPPT_YG_DIBAYAR)), 0)
                         JUM_TAHUN_5,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 5, DENDA_SPPT)), 0) DENDA_5,
                      NVL (
                         SUM(DECODE (KATEGORI_TAHUN,
                                     5,
                                     JML_SPPT_YG_DIBAYAR - DENDA_SPPT)),
                         0
                      )
                         POKOK_5,
                      (COUNT (DECODE (KATEGORI_TAHUN, 6, 1))) STTS_TAHUN_6,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 6, JML_SPPT_YG_DIBAYAR)), 0)
                         JUM_TAHUN_6,
                      NVL (SUM (DECODE (KATEGORI_TAHUN, 6, DENDA_SPPT)), 0) DENDA_6,
                      NVL (
                         SUM(DECODE (KATEGORI_TAHUN,
                                     6,
                                     JML_SPPT_YG_DIBAYAR - DENDA_SPPT)),
                         0
                      )
                         POKOK_6
               FROM   (SELECT   KD_PROPINSI,
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
                                TRUNC (TGL_PEMBAYARAN_SPPT) AS TGL_BAYAR,
                                CASE
                                   WHEN THN_PAJAK_SPPT = 2018
                                   THEN
                                      '0'
                                   WHEN THN_PAJAK_SPPT = 2018 - 1
                                   THEN
                                      '1'
                                   WHEN THN_PAJAK_SPPT = 2018 - 2
                                   THEN
                                      '2'
                                   WHEN THN_PAJAK_SPPT = 2018 - 3
                                   THEN
                                      '3'
                                   WHEN THN_PAJAK_SPPT = 2018 - 4
                                   THEN
                                      '4'
                                   WHEN THN_PAJAK_SPPT = 2018 - 5
                                   THEN
                                      '5'
                                   ELSE
                                      '6'
                                END
                                   AS KATEGORI_TAHUN
                         FROM   pembayaran_sppt where thn_pajak_sppt <= 2018) pembayaran
           GROUP BY   KD_PROPINSI,
                      KD_DATI2,
                      KD_KECAMATAN,
                      KD_KELURAHAN,
                      TGL_BAYAR)
              view_terima_detail_kel
                    where trunc(tgl_bayar) between to_date('01/01/2018','DD/MM/YYYY') and to_date('10/12/2018','DD/MM/YYYY'))
                    penerimaan
                    on kel.kd_propinsi=penerimaan.kd_propinsi
                    and kel.kd_dati2=penerimaan.kd_dati2
                    and kel.kd_kecamatan=penerimaan.kd_kecamatan
                    and kel.kd_kelurahan=penerimaan.kd_kelurahan
                    group by kel.KD_KECAMATAN,kel.kd_kelurahan,kel.nm_kelurahan;
```

* ambil BAKU_WP & BAKU_NOMINAL 1 KABUPATEN
```sql
select count(s.KD_PROPINSI) as WP, sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) as NOMINAL, s.KD_KECAMATAN, s.KD_KELURAHAN, k.NM_KECAMATAN , k.NM_KELURAHAN
from SPPT s
left join VIEW_KELURAHAN k on s.KD_PROPINSI = k.KD_PROPINSI and
        s.KD_DATI2 = k.KD_DATI2 and
        s.KD_KECAMATAN = k.KD_KECAMATAN and
        s.KD_KELURAHAN = k.KD_KELURAHAN
where s.THN_PAJAK_SPPT=2018
group by s.KD_KECAMATAN, s.KD_KELURAHAN,k.NM_KECAMATAN, k.NM_KELURAHAN;
```

* ambil nomor urut max per blok
```sql
select max(s.NO_URUT)
from SPPT s
where s.KD_KECAMATAN=080, s.KD_KELURAHAN=001, s.KD_BLOK=001
```

* tunggakan detail per kelurahan
```sql
select *
from view_sppt_op
where kd_kecamatan=020 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=030 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=031 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=040 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=050 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=051 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=060 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=070 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=080 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=090 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=100 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=111 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=120 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=130 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=140 and status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where kd_kecamatan=150 and status_pembayaran_sppt <> 1
```
