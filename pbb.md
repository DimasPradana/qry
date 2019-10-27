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
where s.KD_KECAMATAN=080, s.KD_KELURAHAN=001, s.KD_BLOK=001;
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

* menu monitoring - tunggakan summmary per kecamatan
```sql
select
                    kel.kd_kelurahan,
                    kel.nm_kelurahan,
                    nvl(sum(penerimaan.stts),0) as stts,
                    nvl(sum(penerimaan.pokok),0) as pokok
                    from (select * from ref_kelurahan where kd_kecamatan='080') kel left join
                    (select kd_propinsi,kd_dati2,kd_kecamatan,kd_kelurahan,count(*) as stts,sum(pbb_yg_harus_dibayar_sppt) as pokok from view_sppt_op
                    where status_pembayaran_sppt <> 1
                    and thn_pajak_sppt='2019' and kd_kecamatan='080' group by kd_propinsi,kd_dati2,kd_kecamatan,kd_kelurahan)
                    penerimaan
                    on kel.kd_propinsi=penerimaan.kd_propinsi
                    and kel.kd_dati2=penerimaan.kd_dati2
                    and kel.kd_kecamatan=penerimaan.kd_kecamatan
                    and kel.kd_kelurahan=penerimaan.kd_kelurahan
                    group by kel.kd_kelurahan,kel.nm_kelurahan order by kel.kd_kelurahan
```

* cari NOP selisih pembayaran yg belum ter-flag oleh sistem
```sql
select sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) as jumlah, count(s.KD_PROPINSI) as sppt
from PEMBAYARAN_SPPT p
left join SPPT s on s.KD_PROPINSI = p.KD_PROPINSI and
                    s.KD_DATI2 = p.KD_DATI2 and
                    s.KD_KECAMATAN = p.KD_KECAMATAN and
                    s.KD_KELURAHAN = p.KD_KELURAHAN and
                    s.KD_BLOK = p. KD_BLOK and
                    s.NO_URUT = p.NO_URUT and
                    s.KD_JNS_OP = p.KD_JNS_OP and
                    s.THN_PAJAK_SPPT = p.THN_PAJAK_SPPT
where s.STATUS_PEMBAYARAN_SPPT = 0 and
      /*s.KD_KECAMATAN = 110 and
      s.KD_KELURAHAN = 005 and*/
      p.THN_PAJAK_SPPT = 2018 and
      p.TGL_PEMBAYARAN_SPPT between to_date('2018-01-01', 'yyyy-mm-dd') and to_date('2018-12-31', 'yyyy-mm-dd');

-- atau
select *
from PEMBAYARAN_SPPT p
left join SPPT s on s.KD_PROPINSI = p.KD_PROPINSI and
                    s.KD_DATI2 = p.KD_DATI2 and
                    s.KD_KECAMATAN = p.KD_KECAMATAN and
                    s.KD_KELURAHAN = p.KD_KELURAHAN and
                    s.KD_BLOK = p. KD_BLOK and
                    s.NO_URUT = p.NO_URUT and
                    s.KD_JNS_OP = p.KD_JNS_OP and
                    s.THN_PAJAK_SPPT = p.THN_PAJAK_SPPT
where s.STATUS_PEMBAYARAN_SPPT = 0 and
      s.KD_KECAMATAN = 110 and
      s.KD_KELURAHAN = 005 and
      p.THN_PAJAK_SPPT = 2018 and
      p.TGL_PEMBAYARAN_SPPT between to_date('2018-01-01', 'yyyy-mm-dd') and to_date('2018-12-31', 'yyyy-mm-dd');

// eksekusi
update sppt s
set s.STATUS_PEMBAYARAN_SPPT = 1
where exists(
    select *
    from PEMBAYARAN_SPPT p
    left join SPPT s on s.KD_PROPINSI = p.KD_PROPINSI and
                    s.KD_DATI2 = p.KD_DATI2 and
                    s.KD_KECAMATAN = p.KD_KECAMATAN and
                    s.KD_KELURAHAN = p.KD_KELURAHAN and
                    s.KD_BLOK = p. KD_BLOK and
                    s.NO_URUT = p.NO_URUT and
                    s.KD_JNS_OP = p.KD_JNS_OP and
                    s.THN_PAJAK_SPPT = p.THN_PAJAK_SPPT
    where s.STATUS_PEMBAYARAN_SPPT = 0 and
          s.KD_KECAMATAN = 110 and
          s.KD_KELURAHAN = 005 and
          p.THN_PAJAK_SPPT = 2018 and
          p.TGL_PEMBAYARAN_SPPT between to_date('2018-01-01', 'yyyy-mm-dd') and
              to_date('2018-12-31', 'yyyy-mm-dd'));

```

* mencari pembayaran yg nominal nya tidak sama dengan tagihan di SPPT
```sql
select s.KD_PROPINSI||s.KD_DATI2||s.KD_KECAMATAN||s.KD_KELURAHAN||s.KD_BLOK||s.NO_URUT||s.KD_JNS_OP as NOP,
       p.THN_PAJAK_SPPT as tahun,
       s.PBB_YG_HARUS_DIBAYAR_SPPT as SPPT,
       p.JML_SPPT_YG_DIBAYAR as pembayaran,
       p.DENDA_SPPT as denda,
       p.PEMBAYARAN_SPPT_KE as siklus_bayar,
       p.TGL_PEMBAYARAN_SPPT as tgl_bayar
from SPPT s
left join PEMBAYARAN_SPPT p on s.KD_PROPINSI=p.KD_PROPINSI and
                               s.KD_DATI2=p.KD_DATI2 and
                               s.KD_KECAMATAN=p.KD_KECAMATAN and
                               s.KD_KELURAHAN=p.KD_KELURAHAN and
                               s.KD_BLOK=p.KD_BLOK and
                               s.NO_URUT=p.NO_URUT and
                               s.KD_JNS_OP=p.KD_JNS_OP and
                               s.THN_PAJAK_SPPT=p.THN_PAJAK_SPPT
where s.PBB_YG_HARUS_DIBAYAR_SPPT <> p.JML_SPPT_YG_DIBAYAR - p.DENDA_SPPT and
      s.STATUS_PEMBAYARAN_SPPT=1 and
      p.JML_SPPT_YG_DIBAYAR is not null
order by NOP,tahun,siklus_bayar asc;
```

* update tanggal bayar sppt
```sql
-- update tgl bayar di sppt
-- TODO langsung update lunas kalo di pembayaran sudah ada
update sppt s
set s.TGL_PEMBAYARAN_SPPT = (
    select p.TGL_PEMBAYARAN_SPPT
    from PEMBAYARAN_SPPT p
    where p.KD_PROPINSI=s.KD_PROPINSI and
          p.KD_DATI2=s.KD_DATI2 and
          p.KD_KECAMATAN=s.KD_KECAMATAN and
          p.KD_KELURAHAN=s.KD_KELURAHAN and
          p.KD_BLOK=s.KD_BLOK and
          p.NO_URUT=s.NO_URUT and
          p.KD_JNS_OP=s.KD_JNS_OP and
          p.THN_PAJAK_SPPT=s.THN_PAJAK_SPPT and
          p.THN_PAJAK_SPPT =2018 and
          p.KD_KECAMATAN=080
    )
where EXISTS(
    select p.TGL_PEMBAYARAN_SPPT
    from PEMBAYARAN_SPPT p
    where p.KD_PROPINSI=s.KD_PROPINSI and
          p.KD_DATI2=s.KD_DATI2 and
          p.KD_KECAMATAN=s.KD_KECAMATAN and
          p.KD_KELURAHAN=s.KD_KELURAHAN and
          p.KD_BLOK=s.KD_BLOK and
          p.NO_URUT=s.NO_URUT and
          p.KD_JNS_OP=s.KD_JNS_OP and
          p.THN_PAJAK_SPPT=s.THN_PAJAK_SPPT and
          p.THN_PAJAK_SPPT =2018 and
          p.KD_KECAMATAN=080);

-- check
select count(*)
from sppt where KD_KECAMATAN=080 and THN_PAJAK_SPPT=2018 and STATUS_PEMBAYARAN_SPPT =1;

-- update status nol jadi 1 dari tgl bayar di sppt
update SPPT s
set s.STATUS_PEMBAYARAN_SPPT = 1
where s.TGL_PEMBAYARAN_SPPT is not null and s.KD_KECAMATAN=090 and s.THN_PAJAK_SPPT=2018 and s.STATUS_PEMBAYARAN_SPPT=0;
```

* query menu tunggakan detail kelurahan
```sql
-- verifikasi PBB detail kelurahan
select *
from view_sppt_op
where kd_kecamatan=050
    and kd_kelurahan=005
    and status_pembayaran_sppt <> 1
    and thn_pajak_sppt=2014
union
select *
from view_sppt_op
where
    kd_kecamatan=050
    and kd_kelurahan=005
    and thn_pajak_sppt=2014
    AND KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
    IN (SELECT
                KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
        FROM PEMBAYARAN_SPPT
        WHERE kd_kecamatan=050
                and kd_kelurahan=005 and thn_pajak_sppt=2014 AND TGL_PEMBAYARAN_SPPT > TO_DATE('31/12/2018','DD/MM/YYYY'));
-- verifikasi PBB all kabupaten
select *
from view_sppt_op
where
    status_pembayaran_sppt <> 1
union
select *
from view_sppt_op
where
    KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
    IN (SELECT
               KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
        FROM PEMBAYARAN_SPPT
    WHERE TGL_PEMBAYARAN_SPPT > TO_DATE('31/12/2018','DD/MM/YYYY'));
```


* menu monitoring - tunggakan semua kecamatan
```sql

select
       kel.kd_kelurahan,
       kel.nm_kelurahan,
       nvl(sum(penerimaan.stts),0) as stts,
       nvl(sum(penerimaan.pokok),0) as pokok
from (
    select *
    from ref_kelurahan
    --  where kd_kecamatan='080') kel
    ) kel
    left join (
        select
               kd_propinsi,
               kd_dati2,
               kd_kecamatan,
               kd_kelurahan,
               count(*) as stts,
               sum(pbb_yg_harus_dibayar_sppt) as pokok
        from (
            select *
            from view_sppt_op
            where
                  --  kd_kecamatan='080'
                  --  kd_kecamatan=
              --  and status_pembayaran_sppt <> 1
              status_pembayaran_sppt <> 1
              and thn_pajak_sppt between '2010' and '2013'
            union
            select *
            from view_sppt_op
            where
                  --  kd_kecamatan='080'
                  --  kd_kecamatan=
              --  and thn_pajak_sppt='2014'
              thn_pajak_sppt between '2010' and '2013'
              and KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
                      IN (
                          SELECT KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
                          FROM PEMBAYARAN_SPPT
                          --  WHERE kd_kecamatan='080'
                          WHERE
                            --  and thn_pajak_sppt='2014'
                            thn_pajak_sppt between '2010' and '2013'
                            AND TGL_PEMBAYARAN_SPPT > TO_DATE('31/12/2013','DD/MM/YYYY') ))
            view_sppt_op
        group by kd_propinsi,kd_dati2,kd_kecamatan,kd_kelurahan) penerimaan
        on kel.kd_propinsi=penerimaan.kd_propinsi
               and kel.kd_dati2=penerimaan.kd_dati2
               and kel.kd_kecamatan=penerimaan.kd_kecamatan
               and kel.kd_kelurahan=penerimaan.kd_kelurahan
group by kel.kd_kelurahan,kel.nm_kelurahan
order by kel.kd_kelurahan;

```

* kebutuhan verifikasi piutang PBB
```sql

-- hitung jumlah obyek pajak di kelurahan
select count(d.KD_PROPINSI), 'jumlah obyek' as ket
from DAT_OBJEK_PAJAK d
where d.KD_KECAMATAN = 120 and d.KD_KELURAHAN=004
union
-- hitung jumlah sppt di kelurahan
select count(s.KD_PROPINSI), 'jumlah sppt' as ket
from SPPT s
where s.KD_KECAMATAN=120 and KD_KELURAHAN=004 and s.THN_PAJAK_SPPT=2019
union
-- hitung fasum di kelurahan
select count(b.KD_PROPINSI), 'jumlah fasum' as ket
from DAT_OP_BUMI b
where b.JNS_BUMI = 4 and b.KD_KECAMATAN =120 and b.KD_KELURAHAN=004;

-- ambil data
select d.kd_propinsi||'-'||d.kd_dati2||'-'||d.kd_kecamatan||'-'||d.kd_kelurahan||'-'||d.kd_blok||'-'||d.no_urut||'-'||d.KD_JNS_OP as NOP,
       s.NM_WP_SPPT as NAMA,
       s.THN_PAJAK_SPPT as THN_PAJAK,
       s.PBB_YG_HARUS_DIBAYAR_SPPT as TAGIHAN,
--        s.STATUS_PEMBAYARAN_SPPT as LUNAS,
       (case when s.STATUS_PEMBAYARAN_SPPT = 1 then 'Lunas' else 'Tidak Lunas' end) as LUNAS,
--        b.JNS_BUMI as JENIS_BUMI
       (case
           when b.JNS_BUMI = 1 then 'TANAH DAN BANGUNAN'
           when b.JNS_BUMI = 2 then 'TANAH KAVLING SIAP BANGUN'
           when b.JNS_BUMI = 3 then 'TANAH KOSONG'
           when b.JNS_BUMI = 4 then 'FASUM' end) as JENIS_BUMI
    from DAT_OBJEK_PAJAK d
    left join SPPT s on d.KD_PROPINSI = s.KD_PROPINSI
                        and d.KD_DATI2 = s.KD_DATI2
                        and d.KD_KECAMATAN = s.KD_KECAMATAN
                        and d.KD_KELURAHAN = s.KD_KELURAHAN
                        and d.KD_BLOK = s.KD_BLOK
                        and d.NO_URUT = s.NO_URUT
    left join DAT_OP_BUMI b on d.KD_PROPINSI = b.KD_PROPINSI
                               and d.KD_DATI2 = b.KD_DATI2
                               and d.KD_KECAMATAN = b.KD_KECAMATAN
                               and d.KD_KELURAHAN = b.KD_KELURAHAN
                               and d.KD_BLOK = b.KD_BLOK
                               and d.NO_URUT = b.NO_URUT
    left join PEMBAYARAN_SPPT p on s.KD_PROPINSI = p.KD_PROPINSI
                                    and s.KD_DATI2 = p.KD_DATI2
                                    and s.KD_KECAMATAN = p.KD_KECAMATAN
                                    and s.KD_KELURAHAN = p.KD_KELURAHAN
                                    and s.KD_BLOK = p.KD_BLOK
                                    and s.NO_URUT = p.NO_URUT
                                    and s.THN_PAJAK_SPPT = p.THN_PAJAK_SPPT
    where d.KD_KECAMATAN = 120 and d.KD_KELURAHAN = 004
-- order by d.KD_PROPINSI,
--          d.KD_DATI2,
--          d.KD_KECAMATAN,
--          d.KD_KELURAHAN,
--          d.KD_BLOK,
--          d.NO_URUT,
--          d.KD_JNS_OP,
--          s.THN_PAJAK_SPPT,
--          b.JNS_BUMI ASC
union
select d1.kd_propinsi||'-'||d1.kd_dati2||'-'||d1.kd_kecamatan||'-'||d1.kd_kelurahan||'-'||d1.kd_blok||'-'||d1.no_urut||'-'||d1.KD_JNS_OP as NOP,
       s1.NM_WP_SPPT as NAMA,
       s1.THN_PAJAK_SPPT as THN_PAJAK,
       s1.PBB_YG_HARUS_DIBAYAR_SPPT as TAGIHAN,
--        s.STATUS_PEMBAYARAN_SPPT as LUNAS,
       (case when s1.STATUS_PEMBAYARAN_SPPT = 1 then 'Lunas' else 'Tidak Lunas' end) as LUNAS,
--        b.JNS_BUMI as JENIS_BUMI
       (case
           when b1.JNS_BUMI = 1 then 'TANAH DAN BANGUNAN'
           when b1.JNS_BUMI = 2 then 'TANAH KAVLING SIAP BANGUN'
           when b1.JNS_BUMI = 3 then 'TANAH KOSONG'
           when b1.JNS_BUMI = 4 then 'FASUM' end) as JENIS_BUMI
    from DAT_OBJEK_PAJAK d1
    left join SPPT s1 on d1.KD_PROPINSI = s1.KD_PROPINSI
                        and d1.KD_DATI2 = s1.KD_DATI2
                        and d1.KD_KECAMATAN = s1.KD_KECAMATAN
                        and d1.KD_KELURAHAN = s1.KD_KELURAHAN
                        and d1.KD_BLOK = s1.KD_BLOK
                        and d1.NO_URUT = s1.NO_URUT
    left join DAT_OP_BUMI b1 on d1.KD_PROPINSI = b1.KD_PROPINSI
                               and d1.KD_DATI2 = b1.KD_DATI2
                               and d1.KD_KECAMATAN = b1.KD_KECAMATAN
                               and d1.KD_KELURAHAN = b1.KD_KELURAHAN
                               and d1.KD_BLOK = b1.KD_BLOK
                               and d1.NO_URUT = b1.NO_URUT
    left join PEMBAYARAN_SPPT p1 on s1.KD_PROPINSI = p1.KD_PROPINSI
                                    and s1.KD_DATI2 = p1.KD_DATI2
                                    and s1.KD_KECAMATAN = p1.KD_KECAMATAN
                                    and s1.KD_KELURAHAN = p1.KD_KELURAHAN
                                    and s1.KD_BLOK = p1.KD_BLOK
                                    and s1.NO_URUT = p1.NO_URUT
                                    and s1.THN_PAJAK_SPPT = p1.THN_PAJAK_SPPT
    where d1.KD_KECAMATAN = 120 and d1.KD_KELURAHAN = 004 and b1.JNS_BUMI =4
union
select d1.kd_propinsi||'-'||d1.kd_dati2||'-'||d1.kd_kecamatan||'-'||d1.kd_kelurahan||'-'||d1.kd_blok||'-'||d1.no_urut||'-'||d1.KD_JNS_OP as NOP,
       s1.NM_WP_SPPT as NAMA,
       s1.THN_PAJAK_SPPT as THN_PAJAK,
       s1.PBB_YG_HARUS_DIBAYAR_SPPT as TAGIHAN,
--        s.STATUS_PEMBAYARAN_SPPT as LUNAS,
       (case when s1.STATUS_PEMBAYARAN_SPPT = 1 then 'Lunas' else 'Tidak Lunas' end) as LUNAS,
--        b.JNS_BUMI as JENIS_BUMI
       (case
           when b1.JNS_BUMI = 1 then 'TANAH DAN BANGUNAN'
           when b1.JNS_BUMI = 2 then 'TANAH KAVLING SIAP BANGUN'
           when b1.JNS_BUMI = 3 then 'TANAH KOSONG'
           when b1.JNS_BUMI = 4 then 'FASUM' end) as JENIS_BUMI
    from DAT_OBJEK_PAJAK d1
    left join SPPT s1 on d1.KD_PROPINSI = s1.KD_PROPINSI
                        and d1.KD_DATI2 = s1.KD_DATI2
                        and d1.KD_KECAMATAN = s1.KD_KECAMATAN
                        and d1.KD_KELURAHAN = s1.KD_KELURAHAN
                        and d1.KD_BLOK = s1.KD_BLOK
                        and d1.NO_URUT = s1.NO_URUT
    left join DAT_OP_BUMI b1 on d1.KD_PROPINSI = b1.KD_PROPINSI
                               and d1.KD_DATI2 = b1.KD_DATI2
                               and d1.KD_KECAMATAN = b1.KD_KECAMATAN
                               and d1.KD_KELURAHAN = b1.KD_KELURAHAN
                               and d1.KD_BLOK = b1.KD_BLOK
                               and d1.NO_URUT = b1.NO_URUT
    left join PEMBAYARAN_SPPT p1 on s1.KD_PROPINSI = p1.KD_PROPINSI
                                    and s1.KD_DATI2 = p1.KD_DATI2
                                    and s1.KD_KECAMATAN = p1.KD_KECAMATAN
                                    and s1.KD_KELURAHAN = p1.KD_KELURAHAN
                                    and s1.KD_BLOK = p1.KD_BLOK
                                    and s1.NO_URUT = p1.NO_URUT
                                    and s1.THN_PAJAK_SPPT = p1.THN_PAJAK_SPPT
    where d1.KD_KECAMATAN = 120 and d1.KD_KELURAHAN = 004 and d1.KD_JNS_OP = 9
order by NOP asc ;
```

* analyze table
```sql
ANALYZE TABLE SPPT COMPUTE STATISTICS ;
```

* check yang status di SPPT = 0 dan sudah ada pembayaran di tabel pembayaran
```sql
select s.KD_PROPINSI||'-'||s.KD_DATI2||'-'||s.KD_KECAMATAN||'-'||s.KD_KELURAHAN||'-'||s.KD_BLOK||'-'||s.NO_URUT||'-'||s.KD_JNS_OP as NOP,
       s.STATUS_PEMBAYARAN_SPPT,
       s.THN_PAJAK_SPPT as thn_sppt,
       ps.TGL_PEMBAYARAN_SPPT,
       ps.THN_PAJAK_SPPT as thn_4m_bayar
from SPPT s
left join PEMBAYARAN_SPPT ps on ps.KD_PROPINSI = s.KD_PROPINSI and
                                ps.KD_DATI2 = s.KD_DATI2 and
                                ps.KD_KECAMATAN = s.KD_KECAMATAN and
                                ps.KD_KELURAHAN = s.KD_KELURAHAN and
                                ps.KD_BLOK = s.KD_BLOK and
                                ps.NO_URUT = s.NO_URUT and
                                ps.THN_PAJAK_SPPT = s.THN_PAJAK_SPPT
where s.STATUS_PEMBAYARAN_SPPT = 0 and ps.KD_PROPINSI is not null ;
```

* SPPT VS DAFNOM_PIUTANG
```sql
/* TODO SPPT VS DAFNOM PIUTANG
   - cari per kecamatan dengan tahun pajak
   - jika piutang yg dicari yg tidak ada di dafnom pakai not exist
   - jika piutang yg dicari yg ada di dafnom pakai exist
 */
select s.KD_KECAMATAN||'-'||s.KD_KELURAHAN||'-'||s.KD_BLOK||'-'||s.NO_URUT||'-'||s.KD_JNS_OP as nopSPPT,
       s.STATUS_PEMBAYARAN_SPPT as statusSPPT,
       s.THN_PAJAK_SPPT as thnSPPT
from SPPT s
where s.STATUS_PEMBAYARAN_SPPT = 0 and
      s.KD_KECAMATAN = $(kec) and
      s.THN_PAJAK_SPPT < 2014 and
      not exists(
          select *
          from dafnom_piutang p
          where p.KD_PROPINSI = s.KD_PROPINSI and
                              p.KD_DATI2 = s.KD_DATI2 and
                              p.KD_KECAMATAN = s.KD_KECAMATAN and
                              p.KD_KELURAHAN = s.KD_KELURAHAN and
                              p.KD_BLOK = s.KD_BLOK and
                              p.NO_URUT = s.NO_URUT and
                              p.THN_PAJAK_SPPT = s.THN_PAJAK_SPPT and
                              p.THN_PEMBENTUKAN = 2013)
order by nopSPPT, thnSPPT asc;
```
