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
