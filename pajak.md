# QUERY PDL
* PDL rekap per rekening
```sql
select '4.1.1.01' AS `Rekening`,
    'Pajak Hotel'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.01' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.01' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.1.01' and s.TanggalEntri between '2019-01-01' and curdate()

union

select '4.1.1.02' AS `Rekening`,
    'Pajak Restoran'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.02' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.02' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.1.02'  and s.TanggalEntri between '2019-01-01' and curdate()

union

select '4.1.1.03' AS `Rekening`,
    'Pajak Hiburan'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.03' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.03' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.1.03'  and s.TanggalEntri between '2019-01-01' and curdate()

union

select '4.1.1.04' AS `Rekening`,
    'Reklame'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.04' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.04' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.1.04'  and s.TanggalEntri between '2019-01-01' and curdate()

union

select '4.1.1.07' AS `Rekening`,
    'Pajak Parkir'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.07' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.07' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.1.07'  and s.TanggalEntri between '2019-01-01' and curdate()

union

select '4.1.1.08' AS `Rekening`,
    'Pajak Air Tanah'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.08' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.08' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.1.08'  and s.TanggalEntri between '2019-01-01' and curdate()

union

select '4.1.1.11' AS `Rekening`,
    'Pajak Mineral Bukan Logam dan Batuan'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.11' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.1.11' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.1.11'  and s.TanggalEntri between '2019-01-01' and curdate()

union

select '4.1.2.02' AS `Rekening`,
    'Retribusi Pemakaian Kekayaan Daerah'  AS `JenisPajak`,
    count(s.Nomor_SKPRD) as Ketetapan,
    sum(d.JumlahPajak) as SKP_Ketetapan,

    (select
      count(s.Nomor_SKPRD) as nomor_skp_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.2.02' and s.Lunas =1) as SKP_Terbayar,

    (select
      sum(d.JumlahPajak) as nom_byr
    from sptpd d
    left join skp s on
          s.Nomor_SPTPD = d.NoID
    left join tarif_dasar_pajak t on
          t.NoID = d.ObyekPajak
    where s.Aktif = 1 and d.JenisPajak like '4.1.2.02' and s.Lunas =1) as Terbayar

from sptpd d
left join skp s on
        s.Nomor_SPTPD = d.NoID
left join tarif_dasar_pajak t on
        t.NoID = d.ObyekPajak
where s.Aktif = 1 and d.JenisPajak like '4.1.2.02'  and s.TanggalEntri between '2019-01-01' and curdate();
```

* rincian denda dari offline dan online tahun 2018
```sql
select s.Nomor_SKPRD as nomor_skprd, s.masa1 as masa1, s.masa2 as masa2, s.TanggalEntri as tgl_entri,
       s.TglBayar as tgl_bayar_on, p.Pokok as pokok_bayar_on, p.Denda as denda_bayar_on,
       t.tanggal_bayar as tgl_bayar_off, d.JumlahPajak as pokok_bayar_off, t.terbayar as total_bayar_off
from skp_2018 s
left join payment_2018 p on p.Pengesahan = s.Pengesahan
left join sptpd_2018 d on d.noid = s.Nomor_SPTPD
left join tandabayar_2018 t on t.nomor_skprd = s.Nomor_SKPRD
where s.Lunas = 1;
```

* query laporan SKP penetapan
```sql
select skp.tanggalentri as Tanggal_Entri,
    skp.tglbayar as Tanggal_Bayar,
    skp.nomor_skprd as Nomor_SKPRD,
    skp.DataEntri as Data_Entri,
    sptpd.namawp as Wajib_Pajak,
    sptpd.keteranganpajak as Uraian,
    sptpd.jumlahpajak as Ketetapan,
    payment.pokok as Terbayar_online,
    payment.denda as denda_online,
    skp.Penyetor as Penyetor,
    skp.masa1 as Masa_1,
    skp.masa2 as Masa_2,
    sptpd.jenispajak,
    skp.lunas as Lunas,
    tarif_dasar_pajak.noid as tdp_id,
    tarif_dasar_pajak.obyekpajak as Nama_Rekening,
    tarif_dasar_pajak.rekeninginduk as Kode_Rekening
from skp
    left join sptpd on sptpd.noid=skp.nomor_sptpd
    left join tarif_dasar_pajak on sptpd.obyekpajak=tarif_dasar_pajak.noid
    left join payment on skp.pengesahan=payment.pengesahan
where
    skp.tanggalentri between {daterange,RANGE1} and {daterange,RANGE2}
        and skp.keterangan=0 and skp.aktif=1
order by tarif_dasar_pajak.RekeningInduk
```
