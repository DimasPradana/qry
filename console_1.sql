select *
from sppt a
where a.STATUS_PEMBAYARAN_SPPT in ('1')
  and a.KD_KECAMATAN = 060
  and a.KD_KELURAHAN = 007
  and a.THN_PAJAK_SPPT = 2013
  and exists(
        select *
        from pembayaran_sppt b
        where a.KD_KECAMATAN = b.KD_KECAMATAN
          and a.KD_KELURAHAN = b.KD_KELURAHAN
          and a.KD_BLOK = b.KD_BLOK
          and a.NO_URUT = b.NO_URUT
          and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
    );

select a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-' ||
       a.THN_PAJAK_SPPT                     as nop,
       a.PBB_YG_HARUS_DIBAYAR_SPPT          as nominal,
       b.KD_KECAMATAN || '-' || b.KD_KELURAHAN || '-' || b.KD_BLOK || '-' || b.NO_URUT || '-' ||
       b.THN_PAJAK_SPPT                     as nop_bayar,
       b.JML_SPPT_YG_DIBAYAR - b.DENDA_SPPT as nominal_bayar,
       b.TGL_REKAM_BYR_SPPT                 as rekam,
       b.TGL_PEMBAYARAN_SPPT                as tgl
from sppt a
         left join PEMBAYARAN_SPPT b on a.KD_KECAMATAN = b.KD_KECAMATAN
    and a.KD_KELURAHAN = b.KD_KELURAHAN
    and a.KD_BLOK = b.KD_BLOK
    and a.NO_URUT = b.NO_URUT
    and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
where a.PBB_YG_HARUS_DIBAYAR_SPPT <> b.JML_SPPT_YG_DIBAYAR - b.DENDA_SPPT
  and a.KD_KECAMATAN = 080
  and a.KD_KELURAHAN = 003
  and a.THN_PAJAK_SPPT = 2015;


select *
from sppt a
where a.PBB_YG_HARUS_DIBAYAR_SPPT = 24200
  and a.KD_KECAMATAN = 060
  and a.KD_KELURAHAN = 007
  and a.THN_PAJAK_SPPT = 2013;


select *
from sppt a
where a.STATUS_PEMBAYARAN_SPPT in ('0')
-- where a.STATUS_PEMBAYARAN_SPPT in ('0', '4')
--   and a.KD_KECAMATAN = 110
--   and a.KD_KELURAHAN = 006
--   and a.THN_PAJAK_SPPT = 2019
  and exists(
        select *
        from PEMBAYARAN_SPPT b
        where a.KD_KECAMATAN = b.KD_KECAMATAN
          and a.KD_KELURAHAN = b.KD_KELURAHAN
          and a.KD_BLOK = b.KD_BLOK
          and a.NO_URUT = b.NO_URUT
          and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
    );

select *
from sppt a
where a.STATUS_PEMBAYARAN_SPPT = 1
  and a.KD_KECAMATAN = 080
  and a.KD_KELURAHAN = 003
  and a.THN_PAJAK_SPPT = 2015
  and not exists(
        select *
        from PEMBAYARAN_SPPT b
        where a.KD_KECAMATAN = b.KD_KECAMATAN
          and a.KD_KELURAHAN = b.KD_KELURAHAN
          and a.KD_BLOK = b.KD_BLOK
          and a.NO_URUT = b.NO_URUT
          and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
    );


-- TODO baku 2019
select count(s.KD_PROPINSI)             as WP,
       sum(s.PBB_YG_HARUS_DIBAYAR_SPPT) as NOMINAL,
       s.KD_KECAMATAN,
       s.KD_KELURAHAN,
       k.NM_KECAMATAN,
       k.NM_KELURAHAN
from SPPT s
         left join VIEW_KELURAHAN k on s.KD_PROPINSI = k.KD_PROPINSI and
                                       s.KD_DATI2 = k.KD_DATI2 and
                                       s.KD_KECAMATAN = k.KD_KECAMATAN and
                                       s.KD_KELURAHAN = k.KD_KELURAHAN
where s.THN_PAJAK_SPPT = 2019
--   and s.KD_KECAMATAN = 080
group by s.KD_KECAMATAN, s.KD_KELURAHAN, k.NM_KECAMATAN, k.NM_KELURAHAN;


-- TODO menu monitoring - tunggakan
select nvl(sum(stts), 0), nvl(sum(pokok), 0)
from (select kel.kd_kelurahan,
             kel.NM_KELURAHAN,
             nvl(sum(penerimaan.stts), 0)  as stts,
             nvl(sum(penerimaan.pokok), 0) as pokok
      from (select * from ref_kelurahan where kd_kecamatan = '$(kd_kec)') kel
               left join
           (select kd_propinsi,
                   kd_dati2,
                   kd_kecamatan,
                   kd_kelurahan,
                   count(*)                       as stts,
                   sum(pbb_yg_harus_dibayar_sppt) as pokok
            from (select *
                  from view_sppt_op_dimas
                  where kd_kecamatan = '$(kd_kec)'
                    and status_pembayaran_sppt = 0
                    and status_dafnom_piutang in ('1', '11')
-- 				and thn_pajak_sppt='$(tahun)'
                    and thn_pajak_sppt between '1994' and '2013'
                  union
                  select *
                  from view_sppt_op_dimas
                  where kd_kecamatan = '$(kd_kec)'
                    and status_dafnom_piutang in ('1', '11')
-- 				and thn_pajak_sppt='$(tahun)'
                    and thn_pajak_sppt between '1994' and '2013'
                    and KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP ||
                        THN_PAJAK_SPPT
                      IN (SELECT KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT ||
                                 KD_JNS_OP || THN_PAJAK_SPPT
                          FROM PEMBAYARAN_SPPT
                          WHERE kd_kecamatan = '$(kd_kec)'
-- 				and thn_pajak_sppt='$(tahun)'
                            and thn_pajak_sppt between '1994' and '2013'
                            AND TGL_PEMBAYARAN_SPPT > TO_DATE('$(tgl_akhir)', 'DD/MM/YYYY')
                        )) view_sppt_op_dimas
            group by kd_propinsi, kd_dati2, kd_kecamatan, kd_kelurahan) penerimaan
           on kel.kd_propinsi = penerimaan.kd_propinsi
               and kel.kd_dati2 = penerimaan.kd_dati2
               and kel.kd_kecamatan = penerimaan.kd_kecamatan
               and kel.kd_kelurahan = penerimaan.kd_kelurahan
--             group by kel.kd_kelurahan,kel.nm_kelurahan order by kel.kd_kelurahan;
      group by kel.kd_kelurahan, kel.nm_kelurahan
      order by kel.kd_kelurahan);

-- TODO faruk
-- select sum(s.PBB_YG_HARUS_DIBAYAR_SPPT)
select s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '/' ||
       s.PBB_YG_HARUS_DIBAYAR_SPPT || '/' || s.THN_PAJAK_SPPT
from sppt s
where s.KD_KECAMATAN = '$(kec)'
  and s.THN_PAJAK_SPPT between '$(thnawal)' and '$(thnakhir)'
--   and s.THN_PAJAK_SPPT = '$(thn)'
  and s.STATUS_DAFNOM_PIUTANG in ('1', '11')
--   and s.KD_KELURAHAN = '$(kel)'
--      and s.KD_BLOK = '$(blok)'
--     and s.KD_BLOK between '017' and '018'
-- and s.NO_URUT between '0001' and '0010'
--   and s.NO_URUT ='$(urut)'
  and s.PBB_YG_HARUS_DIBAYAR_SPPT between '200000' and '500000'
  and s.STATUS_PEMBAYARAN_SPPT = 1
  and not exists(
        select *
        from PEMBAYARAN_SPPT p
        where p.KD_PROPINSI = s.KD_PROPINSI
          and p.KD_DATI2 = s.KD_DATI2
          and p.KD_KECAMATAN = s.KD_KECAMATAN
          and p.KD_KELURAHAN = s.KD_KELURAHAN
          and p.KD_BLOK = s.KD_BLOK
          and p.NO_URUT = s.NO_URUT
          and p.THN_PAJAK_SPPT = s.THN_PAJAK_SPPT
    )
order by s.PBB_YG_HARUS_DIBAYAR_SPPT desc;

-- TODO mencari per blok
select sum(s.PBB_YG_HARUS_DIBAYAR_SPPT), count(s.PBB_YG_HARUS_DIBAYAR_SPPT)
from sppt s
-- update sppt s set s.STATUS_PEMBAYARAN_SPPT = 0
where s.KD_KECAMATAN = '$(kec)'
  and s.KD_KELURAHAN between '001' and '001'
--   and s.KD_KELURAHAN = '$(kel)'
  and s.THN_PAJAK_SPPT between '$(thnawal)' and '$(thnakhir)'
--   and s.THN_PAJAK_SPPT = '$(thn)'
  and s.STATUS_DAFNOM_PIUTANG in ('1', '11')
--      and s.KD_BLOK = '$(blok)'
  and s.KD_BLOK between '001' and '016'
--     ' and '004'
  and s.NO_URUT between '0001' and '0023'
--   and s.NO_URUT ='$(urut)'
  and s.STATUS_PEMBAYARAN_SPPT = 1
  and not exists(
        select *
        from PEMBAYARAN_SPPT p
        where p.KD_PROPINSI = s.KD_PROPINSI
          and p.KD_DATI2 = s.KD_DATI2
          and p.KD_KECAMATAN = s.KD_KECAMATAN
          and p.KD_KELURAHAN = s.KD_KELURAHAN
          and p.KD_BLOK = s.KD_BLOK
          and p.NO_URUT = s.NO_URUT
          and p.THN_PAJAK_SPPT = s.THN_PAJAK_SPPT
    );

select count(*)
from sppt a
where a.STATUS_PEMBAYARAN_SPPT = 0
  and a.KD_KECAMATAN = 111
  and a.STATUS_DAFNOM_PIUTANG in ('1', '11')
  and a.THN_PAJAK_SPPT between 1994 and 2013;

select count(KD_PROPINSI)
from sppt a
where a.KD_KECAMATAN = 080
  and a.KD_KELURAHAN = 004
  and a.STATUS_PEMBAYARAN_SPPT in ('3', '4')
  and a.THN_PAJAK_SPPT = 1994
  and exists(select *
             from PEMBAYARAN_SPPT b
             where b.KD_KECAMATAN = a.KD_KECAMATAN
               and b.KD_KELURAHAN = a.KD_KELURAHAN
               and b.KD_BLOK = a.KD_BLOK
               and b.NO_URUT = a.NO_URUT
               and b.THN_PAJAK_SPPT = a.THN_PAJAK_SPPT
               and b.TGL_PEMBAYARAN_SPPT between to_date('01/01/2019', 'dd/mm/yyyy') and to_date('31/12/2019', 'dd/mm/yyyy'));



select *
from pembayaran_sppt a
         left join sppt b on a.KD_KECAMATAN = b.KD_KECAMATAN
    and b.KD_KELURAHAN = a.KD_KELURAHAN
    and b.KD_BLOK = a.KD_BLOK
    and b.NO_URUT = a.NO_URUT
    and b.THN_PAJAK_SPPT = a.THN_PAJAK_SPPT
where a.KD_KECAMATAN = 080
  and a.KD_KELURAHAN = 004
  and a.THN_PAJAK_SPPT = 1994
  and a.TGL_PEMBAYARAN_SPPT between to_date('01-01-2019'
    , 'dd-mm-yyyy')
    and to_date('31-12-2019'
        , 'dd-mm-yyyy')
  and b.STATUS_DAFNOM_PIUTANG in ('1', '10');

select sum(a.PBB_YG_HARUS_DIBAYAR_SPPT)
from sppt a
         left join PEMBAYARAN_SPPT b on a.KD_KECAMATAN = b.KD_KECAMATAN
    and a.KD_KELURAHAN = b.KD_KELURAHAN
    and a.KD_BLOK = b.KD_BLOK
    and a.NO_URUT = b.NO_URUT
    and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
where a.KD_KECAMATAN = 080
  and a.THN_PAJAK_SPPT between 1994 and 2013
--   and a.STATUS_DAFNOM_PIUTANG in ('1', '11')
  and a.STATUS_PEMBAYARAN_SPPT in ('3', '4')
  and b.TGL_PEMBAYARAN_SPPT between to_date('01/01/2019', 'dd/mm/yyyy') and to_date('31/12/2019', 'dd/mm/yyyy');

select sum(a.PBB_YG_HARUS_DIBAYAR_SPPT)
from SPPT a
where a.STATUS_DAFNOM_PIUTANG in ('1', '11')
  and a.THN_PAJAK_SPPT < 2014
  and a.STATUS_PEMBAYARAN_SPPT = 0
  and a.KD_KECAMATAN = 080
  and a.KD_KELURAHAN = 001;

select sum(a.JML_SPPT_YG_DIBAYAR - a.DENDA_SPPT)
from PEMBAYARAN_SPPT a
where a.TGL_PEMBAYARAN_SPPT between to_date('01/01/2019', 'dd/mm/yyyy') and to_date('31/01/2019', 'dd/mm/yyyy')
  and a.KD_KECAMATAN = 080
  and a.KD_KELURAHAN = 004
  and a.THN_PAJAK_SPPT < 2014;

-- TODO lunas yang tidak ada di pembayaran
select *
from sppt a
-- update sppt a set a.STATUS_PEMBAYARAN_SPPT=0
where a.STATUS_PEMBAYARAN_SPPT = 1
  and a.THN_PAJAK_SPPT = 2019
  and a.KD_KECAMATAN = 110
  and a.KD_KELURAHAN in ('006')
  and not exists
    (select *
     from PEMBAYARAN_SPPT b
     where a.KD_KECAMATAN = b.KD_KECAMATAN
       and a.KD_KELURAHAN = b.KD_KELURAHAN
       and a.KD_BLOK = b.KD_BLOK
       and a.NO_URUT = b.NO_URUT
       and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT);

-- TODO tampilkan nominal sppt yang tidak sama dengan di dafnom piutang
select a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-' || a.THN_PAJAK_SPPT ||
       '\' || a.PBB_YG_HARUS_DIBAYAR_SPPT as sppt,
       b.KD_KECAMATAN || '-' || b.KD_KELURAHAN || '-' || b.KD_BLOK || '-' || b.NO_URUT || '-' || b.THN_PAJAK_SPPT ||
       '\' || b.PBB_YG_HARUS_DIBAYAR_SPPT as dafnom
from sppt a
         left join DAFNOM_PIUTANG b on a.KD_KECAMATAN = b.KD_KECAMATAN
    and a.KD_KELURAHAN = b.KD_KELURAHAN
    and a.KD_BLOK = b.KD_BLOK
    and a.NO_URUT = b.NO_URUT
    and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
where a.STATUS_DAFNOM_PIUTANG = 1
  and a.PBB_YG_HARUS_DIBAYAR_SPPT <> b.PBB_YG_HARUS_DIBAYAR_SPPT
  and b.THN_PEMBENTUKAN = 2014
order by sppt asc;

-- TODO tampilkan sppt yang nominalnya tidak sama dengan pbb terhutang
select *
from SPPT s
where s.KD_KECAMATAN = 140
  and s.KD_KELURAHAN = 002
  and s.THN_PAJAK_SPPT = 2019
  and s.PBB_YG_HARUS_DIBAYAR_SPPT <> s.PBB_TERHUTANG_SPPT
  and s.FAKTOR_PENGURANG_SPPT = 0
  and s.PBB_YG_HARUS_DIBAYAR_SPPT <> 5000;

select *
from SPPT a
where a.KD_KECAMATAN = '$(kec)'
  and a.KD_KELURAHAN = '$(kel)'
  and a.KD_BLOK = '$(blok)'
  and a.NO_URUT = '$(no)'
  and a.THN_PAJAK_SPPT = '$(thn)';

INSERT INTO PBB.PEMBAYARAN_SPPT (KD_PROPINSI, KD_DATI2, KD_KECAMATAN, KD_KELURAHAN, KD_BLOK, NO_URUT, KD_JNS_OP,
                                 THN_PAJAK_SPPT, PEMBAYARAN_SPPT_KE, KD_KANWIL_BANK, KD_KPPBB_BANK, KD_BANK_TUNGGAL,
                                 KD_BANK_PERSEPSI, KD_TP, DENDA_SPPT, JML_SPPT_YG_DIBAYAR, TGL_PEMBAYARAN_SPPT,
                                 TGL_REKAM_BYR_SPPT, NIP_REKAM_BYR_SPPT, JENIS_BAYAR, PAJAK_POOL, CREA_USER, CREA_DATE)
VALUES ('35', '12', '080', '003', '027', '0082', '0', '2019', 1, '12', '10', '00', '00', '04', 2346, 119626,
        TO_DATE('2020-01-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2020-01-06 12:17:12', 'YYYY-MM-DD HH24:MI:SS'), '090909091', null, 'N', null, null);
INSERT INTO PBB.PEMBAYARAN_SPPT (KD_PROPINSI, KD_DATI2, KD_KECAMATAN, KD_KELURAHAN, KD_BLOK, NO_URUT, KD_JNS_OP,
                                 THN_PAJAK_SPPT, PEMBAYARAN_SPPT_KE, KD_KANWIL_BANK, KD_KPPBB_BANK, KD_BANK_TUNGGAL,
                                 KD_BANK_PERSEPSI, KD_TP, DENDA_SPPT, JML_SPPT_YG_DIBAYAR, TGL_PEMBAYARAN_SPPT,
                                 TGL_REKAM_BYR_SPPT, NIP_REKAM_BYR_SPPT, JENIS_BAYAR, PAJAK_POOL, CREA_USER, CREA_DATE)
VALUES ('35', '12', '080', '006', '011', '0003', '0', '2019', 1, '12', '10', '00', '00', '04', 100, 5100,
        TO_DATE('2020-01-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2020-01-06 13:13:46', 'YYYY-MM-DD HH24:MI:SS'), '090909091', null, 'N', null, null);

-- TODO rekap summary kecamatan
select nvl(sum(stts), 0), nvl(sum(pokok), 0)
from (select kel.kd_kelurahan,
             kel.nm_kelurahan,
             nvl(sum(penerimaan.stts), 0)  as stts,
             nvl(sum(penerimaan.pokok), 0) as pokok
      from (select *
            from ref_kelurahan
            where kd_kecamatan = '$(kec)') kel
               left join
           (select kd_propinsi,
                   kd_dati2,
                   kd_kecamatan,
                   kd_kelurahan,
                   count(*)                       as stts,
                   sum(pbb_yg_harus_dibayar_sppt) as pokok
            from (select *
                  from view_sppt_op_dimas
                  where kd_kecamatan = '$(kec)'
                    and status_pembayaran_sppt =0
                    and status_dafnom_piutang in ('1', '11')
-- 				and thn_pajak_sppt= [$tahun]
                    and thn_pajak_sppt between '1994' and '2018'
                  union
                  select *
                  from view_sppt_op_dimas
                  where kd_kecamatan = '$(kec)'
-- 				and thn_pajak_sppt=[$tahun]
                    and thn_pajak_sppt between '1994' and '2018'
                    and KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT || KD_JNS_OP ||
                        THN_PAJAK_SPPT
                      IN (SELECT KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT ||
                                 KD_JNS_OP || THN_PAJAK_SPPT
                          FROM PEMBAYARAN_SPPT
                          WHERE kd_kecamatan ='$(kec)'
-- 				and thn_pajak_sppt=[$tahun]
                            and thn_pajak_sppt between '1994' and '2018'
                            AND TGL_PEMBAYARAN_SPPT > TO_DATE('$(tgl_akhir)'
                , 'DD/MM/YYYY')
                )) view_sppt_op_dimas
                group by kd_propinsi
                , kd_dati2
                , kd_kecamatan
                , kd_kelurahan) penerimaan
            on kel.kd_propinsi = penerimaan.kd_propinsi
                and kel.kd_dati2 = penerimaan.kd_dati2
                and kel.kd_kecamatan = penerimaan.kd_kecamatan
                and kel.kd_kelurahan = penerimaan.kd_kelurahan
--             group by kel.kd_kelurahan,kel.nm_kelurahan order by kel.kd_kelurahan;
            group by kel.kd_kelurahan, kel.nm_kelurahan
            order by kel.kd_kelurahan);

select sum(a.JML_SPPT_YG_DIBAYAR-a.DENDA_SPPT) as pokok, sum(a.DENDA_SPPT) as denda,  sum(a.JML_SPPT_YG_DIBAYAR) as total
from PEMBAYARAN_SPPT a
where a.TGL_PEMBAYARAN_SPPT between to_date('01/01/2019', 'dd/mm/yyyy') and to_date('31/12/2019', 'dd/mm/yyyy');