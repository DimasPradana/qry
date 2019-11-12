// detail per kelurahan
```sql
select *
from view_sppt_op
where kd_kecamatan='$(kec)' and
	kd_kelurahan='$(kel)' and
	status_pembayaran_sppt <> 1 and
	thn_pajak_sppt='$(tahunpajak)'
union
select *
from view_sppt_op
where kd_kecamatan='$(kec)' and
kd_kelurahan='$(kel)' and
thn_pajak_sppt='$(tahunpajak)' and
KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT IN
	(SELECT KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
	FROM PEMBAYARAN_SPPT
	WHERE kd_kecamatan='$(kec)' and
		kd_kelurahan='$(kel)' and
		thn_pajak_sppt='$(tahunpajak)' AND
		TGL_PEMBAYARAN_SPPT > TO_DATE('$(batastanggal)','DD/MM/YYYY') )
```

//summary per kecamatan
```sql
select kel.kd_kelurahan,
	kel.nm_kelurahan,
	nvl(sum(penerimaan.stts),0) as stts,
	nvl(sum(penerimaan.pokok),0) as pokok
from (select *
	from ref_kelurahan
	where kd_kecamatan='$(kec)'
	) kel
left join (select kd_propinsi,
		kd_dati2,
		kd_kecamatan,
		kd_kelurahan,
		count(*) as stts,
		sum(pbb_yg_harus_dibayar_sppt) as pokok
		from (select *
			from view_sppt_op
			where kd_kecamatan='$(kec)' and
				status_pembayaran_sppt <> 1 AND
				thn_pajak_sppt='$(tahunpajak)'
			union
			select *
			from view_sppt_op
			where kd_kecamatan='$(kec)' and
				thn_pajak_sppt='$(tahunpajak)' and
				KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT IN
					(SELECT KD_PROPINSI||KD_DATI2||KD_KECAMATAN||KD_KELURAHAN||KD_BLOK||NO_URUT||KD_JNS_OP||THN_PAJAK_SPPT
					FROM PEMBAYARAN_SPPT
					WHERE kd_kecamatan='$(kec)' and
						thn_pajak_sppt='$(tahunpajak)' AND
						TGL_PEMBAYARAN_SPPT > TO_DATE('$(batastanggal)','DD/MM/YYYY')
					)
			) view_sppt_op
			group by kd_propinsi,kd_dati2,kd_kecamatan,kd_kelurahan
		) penerimaan on kel.kd_propinsi=penerimaan.kd_propinsi and
		kel.kd_dati2=penerimaan.kd_dati2 and
		kel.kd_kecamatan=penerimaan.kd_kecamatan and
		kel.kd_kelurahan=penerimaan.kd_kelurahan
group by kel.kd_kelurahan,kel.nm_kelurahan order by kel.kd_kelurahan
```
