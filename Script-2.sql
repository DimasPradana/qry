select count(s.NoID), 'spt retribusi' as pajak
from sptpd s
where s.TanggalEntri between '2020-07-01' and '2020-09-30' and s.ObyekPajak in ('78','79','80','81','82','83','84','85','86','87','88','89','90','91','93','94','95') 
union
select count(s.Nomor_SKPRD), 'skp' as pajak 
from skp s
left join sptpd s2 on s2.NoID = s.Nomor_SPTPD 
where s2.TanggalEntri between '2020-07-01' and '2020-09-30' and s2.ObyekPajak in ('78','79','80','81','82','83','84','85','86','87','88','89','90','91','93','94','95')
union 
select count(s.NoID), 'spt all' as pajak
from sptpd s
where s.TanggalEntri between '2020-07-01' and '2020-09-30';


select skp.Nomor_SKPRD as nomor_skp, sptpd.KeteranganPajak as uraian, zona_strategis.ruasjalan, sptpd.RuasJalan 
from `e-pajak`.skp
left join `e-pajak`.sptpd on skp.Nomor_SPTPD = sptpd.noid
left join `e-pajak`.tarif_dasar_pajak on sptpd.ObyekPajak = tarif_dasar_pajak.NoID 
left join `e-pajak`.zona_strategis on zona_strategis.NoID = sptpd.RuasJalan 
where sptpd.ObyekPajak between 14 and 24 and sptpd.Aktif = 1 and skp.Aktif = 1
order by zona_strategis.ruasjalan asc ;

select s.Nomor_SKPRD , s.Nomor_SPTPD
from `e-pajak`.skp_2020 s;
