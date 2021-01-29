create view `bphtb_apps_bphtb`.`e_billing_2020` as
select
	`a`.`ID_PENGAJUAN` AS `ID_PENGAJUAN`,
	`a`.`NOP` AS `NOP`,
	`a`.`NO_IDENTITAS_TH` AS `NIK`,
	concat('3512998', convert(date_format(`a`.`TGL_CETAK_EBILLING`, '%d%m%y') using utf8mb4), `a`.`ID_PENGAJUAN`) AS `KODE_BILLING`,
	truncate(if((`b`.`KODE` = '05'), if((if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) < 300000000), 0,(((if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) - 300000000) * 5) / 100)), if((if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) < 60000000),((if(((select count(`e`.`NO_IDENTITAS_TH`) from `bphtb_apps_bphtb`.`pengajuan` `e` where (isnull(`e`.`TGL_ADMINISTRASI_BPPKAD_TOLAK`) and isnull(`e`.`TGL_ADMINISTRASI_DJP_TOLAK`) and isnull(`e`.`TGL_PEMBAYARAN_TOLAK`) and isnull(`e`.`TGL_VALIDASI_TOLAK`) and (`e`.`NO_IDENTITAS_TH` = `a`.`NO_IDENTITAS_TH`))) >= 2), if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`), 0) * 5) / 100),((if(((select count(`e`.`NO_IDENTITAS_TH`) from `bphtb_apps_bphtb`.`pengajuan` `e` where (isnull(`e`.`TGL_ADMINISTRASI_BPPKAD_TOLAK`) and isnull(`e`.`TGL_ADMINISTRASI_DJP_TOLAK`) and isnull(`e`.`TGL_PEMBAYARAN_TOLAK`) and isnull(`e`.`TGL_VALIDASI_TOLAK`) and (`e`.`NO_IDENTITAS_TH` = `a`.`NO_IDENTITAS_TH`))) >= 2), if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`),(if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) - 60000000)) * 5) / 100))), 0) AS `Jumlah_Tagihan_Pokok`,
	concat('0') AS `Jumlah_Tagihan_Denda`,
	truncate(if((`b`.`KODE` = '05'), if((if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) < 300000000), 0,(((if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) - 300000000) * 5) / 100)), if((if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) < 60000000),((if(((select count(`e`.`NO_IDENTITAS_TH`) from `bphtb_apps_bphtb`.`pengajuan` `e` where (isnull(`e`.`TGL_ADMINISTRASI_BPPKAD_TOLAK`) and isnull(`e`.`TGL_ADMINISTRASI_DJP_TOLAK`) and isnull(`e`.`TGL_PEMBAYARAN_TOLAK`) and isnull(`e`.`TGL_VALIDASI_TOLAK`) and (`e`.`NO_IDENTITAS_TH` = `a`.`NO_IDENTITAS_TH`))) >= 2), if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`), 0) * 5) / 100),((if(((select count(`e`.`NO_IDENTITAS_TH`) from `bphtb_apps_bphtb`.`pengajuan` `e` where (isnull(`e`.`TGL_ADMINISTRASI_BPPKAD_TOLAK`) and isnull(`e`.`TGL_ADMINISTRASI_DJP_TOLAK`) and isnull(`e`.`TGL_PEMBAYARAN_TOLAK`) and isnull(`e`.`TGL_VALIDASI_TOLAK`) and (`e`.`NO_IDENTITAS_TH` = `a`.`NO_IDENTITAS_TH`))) >= 2), if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`),(if((`a`.`NJPO_DJP` > `a`.`NJPO_BPPKAD`), `a`.`NJPO_DJP`, `a`.`NJPO_BPPKAD`) - 60000000)) * 5) / 100))), 0) AS `Jumlah_Tagihan_Total`
from
	(`bphtb_apps_bphtb`.`pengajuan_2020` `a`
join `bphtb_apps_bphtb`.`jenis_perolehan` `b` on
	((`b`.`ID_JENIS_PEROLEHAN` = `a`.`ID_JENIS_PEROLEHAN`)))
where
	((`a`.`TGL_CETAK_EBILLING` is not null)
	and ((`a`.`TGL_CETAK_EBILLING` + interval 7 day) >= now())
	and isnull(`a`.`TGL_PEMBAYARAN`));