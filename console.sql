--TODO cek yg tidak ada di pembayaran tapi ada di pembayaran_2
select distinct *
from PEMBAYARAN_SPPT_2 a
where not exists(
        select *
        from PEMBAYARAN_SPPT b
        where a.KD_KECAMATAN = b.KD_KECAMATAN
          and a.KD_KELURAHAN = b.KD_KELURAHAN
          and a.KD_BLOK = b.KD_BLOK
          and a.NO_URUT = b.NO_URUT
          and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
    )
-- and KD_KECAMATAN=070 and KD_KELURAHAN=001 and KD_BLOK=014 and NO_URUT=0065 and THN_PAJAK_SPPT=1997
order by a.KD_KECAMATAN, a.KD_KELURAHAN, a.KD_BLOK, a.NO_URUT, a.THN_PAJAK_SPPT asc;

insert into PEMBAYARAN_SPPT (KD_PROPINSI, KD_DATI2, KD_KECAMATAN, KD_KELURAHAN, KD_BLOK, NO_URUT, KD_JNS_OP,
                             THN_PAJAK_SPPT, PEMBAYARAN_SPPT_KE, KD_KANWIL_BANK, KD_KPPBB_BANK, KD_BANK_TUNGGAL,
                             KD_BANK_PERSEPSI, KD_TP, DENDA_SPPT, JML_SPPT_YG_DIBAYAR, TGL_PEMBAYARAN_SPPT,
                             NIP_REKAM_BYR_SPPT, JENIS_BAYAR, CREA_USER, CREA_DATE)
select distinct KD_PROPINSI,
                KD_DATI2,
                KD_KECAMATAN,
                KD_KELURAHAN,
                KD_BLOK,
                NO_URUT,
                KD_JNS_OP,
                THN_PAJAK_SPPT,
                PEMBAYARAN_SPPT_KE,
                KD_KANWIL_BANK,
                KD_KPPBB_BANK,
                KD_BANK_TUNGGAL,
                KD_BANK_PERSEPSI,
                KD_TP,
                DENDA_SPPT,
                JML_SPPT_YG_DIBAYAR,
                TGL_PEMBAYARAN_SPPT,
                NIP_REKAM_BYR_SPPT,
                JENIS_BAYAR,
                CREA_USER,
                CREA_DATE
from PEMBAYARAN_SPPT_2 a
where not exists(
        select *
        from PEMBAYARAN_SPPT b
        where a.KD_KECAMATAN = b.KD_KECAMATAN
          and a.KD_KELURAHAN = b.KD_KELURAHAN
          and a.KD_BLOK = b.KD_BLOK
          and a.NO_URUT = b.NO_URUT
          and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
    );
-- and KD_KECAMATAN=070 and KD_KELURAHAN=001 and KD_BLOK=014 and NO_URUT=0065 and THN_PAJAK_SPPT=1997;


--TODO cari yg statusnya belum lunas tapi ada di table pembayaran
-- update sppt a
-- set a.STATUS_PEMBAYARAN_SPPT = 1
select *
from sppt a
where a.STATUS_PEMBAYARAN_SPPT = 0
  and exists(
        select *
        from PEMBAYARAN_SPPT b
        where a.KD_KECAMATAN = b.KD_KECAMATAN
          and a.KD_KELURAHAN = b.KD_KELURAHAN
          and a.KD_BLOK = b.KD_BLOK
          and a.NO_URUT = b.NO_URUT
          and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
    );


-- TODO BPK 02-06-2020 pertama
-- yang diambil kecamatan panarukan tahun 2019 saja
select '35-12-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-0' as NOP,
       a.NM_WP_SPPT                                                                                        as nama,
       a.NJOP_SPPT                                                                                         as NJOP,
       a.NJOPTKP_SPPT                                                                                      as njoptkp,
       a.PBB_YG_HARUS_DIBAYAR_SPPT                                                                         as pbb_yg_harus_dibayar,
       b.SUBJEK_PAJAK_ID                                                                                   as NIK,
       b.JALAN_WP                                                                                          as alamat_wp
from SPPT a
         left join DAT_OBJEK_PAJAK c on a.KD_KECAMATAN = c.KD_KECAMATAN and a.KD_KELURAHAN = c.KD_KELURAHAN and
                                        a.KD_BLOK = c.KD_BLOK and a.NO_URUT = c.NO_URUT
         left join DAT_SUBJEK_PAJAK b on c.SUBJEK_PAJAK_ID = b.SUBJEK_PAJAK_ID
where a.THN_PAJAK_SPPT = 2019
  and a.KD_KECAMATAN = 070
  and a.STATUS_DAFNOM_PIUTANG = 11
order by nik asc;

-- TODO BPK 02-06-2020 kedua
select '35-12-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-0' as nop,
       a.THN_PAJAK_SPPT                                                                                    as tahun_pajak,
       a.NM_WP_SPPT                                                                                        as nama,
       b.SUBJEK_PAJAK_ID                                                                                   as NIK,
       a.PBB_YG_HARUS_DIBAYAR_SPPT                                                                         as pbb_yang_harus_dibayar
from SPPT a
         left join DAT_OBJEK_PAJAK b
                   on a.KD_KECAMATAN = b.KD_KECAMATAN and
                      a.KD_KELURAHAN = b.KD_KELURAHAN and a.KD_BLOK = b.KD_BLOK and a.NO_URUT = b.NO_URUT
where a.THN_PAJAK_SPPT in (2015, 2016, 2017, 2018, 2019)
  and a.STATUS_DAFNOM_PIUTANG = 11
  and a.STATUS_PEMBAYARAN_SPPT = 0;


-- TODO BPK piutang 2019
select kel.kd_kelurahan,
       kel.nm_kelurahan,
       nvl(sum(penerimaan.stts), 0)  as stts,
       nvl(sum(penerimaan.pokok), 0) as pokok
from (select * from ref_kelurahan where kd_kecamatan = '$(kec)') kel
         left join (select kd_propinsi,
                           kd_dati2,
                           kd_kecamatan,
                           kd_kelurahan,
                           count(*)                       as stts,
                           sum(pbb_yg_harus_dibayar_sppt) as pokok
                    from (select *
                          from view_sppt_op_dimas
                          where kd_kecamatan = '$(kec)'
                            and status_pembayaran_sppt = 0
                            and status_dafnom_piutang in ('1', '11')
                            and thn_pajak_sppt between '$(thnawal)' and '$(thnakhir)'
                          union
                          select *
                          from view_sppt_op_dimas
                          where kd_kecamatan = '$(kec)'
                            and thn_pajak_sppt between '$(thnawal)' and '$(thnakhir)'
                            and KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT ||
                                KD_JNS_OP || THN_PAJAK_SPPT
                              IN
                                (SELECT KD_PROPINSI || KD_DATI2 || KD_KECAMATAN || KD_KELURAHAN || KD_BLOK || NO_URUT ||
                                        KD_JNS_OP || THN_PAJAK_SPPT
                                 FROM PEMBAYARAN_SPPT
                                 WHERE kd_kecamatan = '$(kec)'
                                   and thn_pajak_sppt between '$(thnawal)' and '$(thnakhir)'
                                   AND TGL_PEMBAYARAN_SPPT > TO_DATE('$(btstgl)', 'DD/MM/YYYY')
                                )) view_sppt_op_dimas
                    group by kd_propinsi, kd_dati2, kd_kecamatan, kd_kelurahan) penerimaan
                   on kel.kd_propinsi = penerimaan.kd_propinsi
                       and kel.kd_dati2 = penerimaan.kd_dati2
                       and kel.kd_kecamatan = penerimaan.kd_kecamatan
                       and kel.kd_kelurahan = penerimaan.kd_kelurahan
group by kel.kd_kelurahan, kel.nm_kelurahan
order by kel.kd_kelurahan;

-- TODO BPK data SPPT terbit 2014 sampai 2019 dengan status dan tanggal bayar
select '35-12-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-0' as NOP,
       a.NM_WP_SPPT                                                                                        as nama,
       a.THN_PAJAK_SPPT                                                                                    as tahun_pajak,
       dop.SUBJEK_PAJAK_ID                                                                                 as NIK,
       a.PBB_YG_HARUS_DIBAYAR_SPPT                                                                         as pbb_yg_harus_dibayar,
       a.STATUS_PEMBAYARAN_SPPT                                                                            as status_bayar,
       b.TGL_PEMBAYARAN_SPPT                                                                               as tanggal_bayar
from view_sppt_op_dimas a
         left join DAT_OBJEK_PAJAK dop on dop.KD_KECAMATAN = a.KD_KECAMATAN and dop.KD_KELURAHAN = a.KD_KELURAHAN and
                                          dop.KD_BLOK = a.KD_BLOK and dop.NO_URUT = a.NO_URUT
         left join pembayaran_sppt b
                   on a.KD_KECAMATAN = b.KD_KECAMATAN and a.KD_KELURAHAN = b.KD_KELURAHAN and a.KD_BLOK = b.KD_BLOK and
                      a.NO_URUT = b.NO_URUT and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
where a.status_pembayaran_sppt = 0
  and a.status_dafnom_piutang in ('1', '11')
  and a.thn_pajak_sppt between '$(thnawal)' and '$(thnakhir)'
union
select '35-12-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-0' as NOP,
       a.NM_WP_SPPT                                                                                        as nama,
       a.THN_PAJAK_SPPT                                                                                    as tahun_pajak,
       dop.SUBJEK_PAJAK_ID                                                                                 as NIK,
       a.PBB_YG_HARUS_DIBAYAR_SPPT                                                                         as pbb_yg_harus_dibayar,
       a.STATUS_PEMBAYARAN_SPPT                                                                            as status_bayar,
       b.TGL_PEMBAYARAN_SPPT                                                                               as tanggal_bayar
from view_sppt_op_dimas a
         left join DAT_OBJEK_PAJAK dop on dop.KD_KECAMATAN = a.KD_KECAMATAN and dop.KD_KELURAHAN = a.KD_KELURAHAN and
                                          dop.KD_BLOK = a.KD_BLOK and dop.NO_URUT = a.NO_URUT
         left join pembayaran_sppt b
                   on a.KD_KECAMATAN = b.KD_KECAMATAN and a.KD_KELURAHAN = b.KD_KELURAHAN and a.KD_BLOK = b.KD_BLOK and
                      a.NO_URUT = b.NO_URUT and a.THN_PAJAK_SPPT = b.THN_PAJAK_SPPT
where a.thn_pajak_sppt between '$(thnawal)' and '$(thnakhir)'
  and a.KD_PROPINSI || a.KD_DATI2 || a.KD_KECAMATAN || a.KD_KELURAHAN || a.KD_BLOK || a.NO_URUT || a.KD_JNS_OP ||
      a.THN_PAJAK_SPPT
    IN (SELECT b.KD_PROPINSI || b.KD_DATI2 || b.KD_KECAMATAN || b.KD_KELURAHAN || b.KD_BLOK || b.NO_URUT ||
               b.KD_JNS_OP ||
               b.THN_PAJAK_SPPT
        FROM PEMBAYARAN_SPPT b
        WHERE b.thn_pajak_sppt between '$(thnawal)' and '$(thnakhir)'
          AND b.TGL_PEMBAYARAN_SPPT > TO_DATE('$(btstgl)', 'DD/MM/YYYY')
      );

-- TODO BPK NOP yg terbit tahun 2018-2019
select '35-12-' || a.KD_KECAMATAN || '-' || a.KD_KELURAHAN || '-' || a.KD_BLOK || '-' || a.NO_URUT || '-0' as NOP,
       a.THN_PAJAK_SPPT                                                                                    as tahun_pajak
from SPPT a
where a.THN_PAJAK_SPPT in (2018, 2019);


-- TODO cari 2019 saja
select '35-12-' || s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '-0' as NOP,
       count(s.THN_PAJAK_SPPT)                                                                             as counter
from SPPT s
where s.THN_PAJAK_SPPT between '2015' and '2019'
  and s.status_dafnom_piutang in ('1', '11')
group by '35-12-' || s.KD_KECAMATAN || '-' || s.KD_KELURAHAN || '-' || s.KD_BLOK || '-' || s.NO_URUT || '-0'
having count(s.THN_PAJAK_SPPT) = 1;


-- TODO hitung jumlah SPPT setiap tahun
select '2014' as tahun,count(a.KD_KECAMATAN)
from sppt a
where a.THN_PAJAK_SPPT = '2014'
and a.STATUS_DAFNOM_PIUTANG in ('1','11')
union
select '2015' as tahun, count(a.KD_KECAMATAN)
from sppt a
where a.THN_PAJAK_SPPT = '2015'
and a.STATUS_DAFNOM_PIUTANG in ('1','11')
union
select '2016' as tahun,count(a.KD_KECAMATAN)
from sppt a
where a.THN_PAJAK_SPPT = '2016'
and a.STATUS_DAFNOM_PIUTANG in ('1','11')
union
select '2017' as tahun, count(a.KD_KECAMATAN)
from sppt a
where a.THN_PAJAK_SPPT = '2017'
and a.STATUS_DAFNOM_PIUTANG in ('1','11')
union
select '2018' as tahun,count(a.KD_KECAMATAN)
from sppt a
where a.THN_PAJAK_SPPT = '2018'
and a.STATUS_DAFNOM_PIUTANG in ('1','11')
union
select '2019' as tahun, count(a.KD_KECAMATAN)
from sppt a
where a.THN_PAJAK_SPPT = '2019'
and a.STATUS_DAFNOM_PIUTANG in ('1','11');