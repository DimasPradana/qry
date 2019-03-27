# query pbb
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
