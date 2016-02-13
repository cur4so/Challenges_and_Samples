select m-su from 
(
  select coalesce(max(r)-min(l),0) as m from segments
) x,
(
  select coalesce(sum(su),0) as su from
  (    
     select jl,min(su) as su from (
     select j.l as jl , j.l-s.r as su   from segments s 
       join segments j on j.l>s.r 
       where s.r not in(
          select s.r from segments s join segments j on s.r>=j.l
             where s.r>=j.l and s.r<j.r) )w group by jl
  )z
)y;
