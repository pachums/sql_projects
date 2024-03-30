/*
CURSO DE SQL BÁSICO

Puedes descargar del dataset desde Kaggle: https://www.kaggle.com/datasets/aadharshviswanath/flight-data/data
*/

-- CAsT()
SELECT CAST(25.65 AS int);

-- Primer vistazo a la tabla
select *
from flight_data fd 

-- COUNT: nos sirve para contar registros
select COUNT(*)
from flight_data fd 

-- TO_DATE(): nos transforma el data_type de la columna
-- GROUP BY: agrupa en base a un criterio
-- ORDER BY: ordena en base a un criterio
select to_date("Date", 'YYYY-MM-DD') as date, count(*)
from flight_data fd 
group by to_date("Date", 'YYYY-MM-DD')
order by date

-- WHERE filtrar
select to_date("Date", 'YYYY-MM-DD') as Date, *
from flight_data fd 
where "Departure_Airport" like 'SEA%' and "Wind_Speed_knots" >= 40

-- EXTRACT(part FROM column): sirve para extraer partes específicas de una fecha u hora.
-- TO_CHAR(value, format): convertir valores de diferentes tipos de datos (fechas y números) en texto basado en un formato específico
select *, to_char(to_date("Date", 'YYYY-MM-DD'), 'Month') 
from flight_data fd 
where extract(month from to_date("Date", 'YYYY-MM-DD')) between 7 and 12

-- DISTINCT seleciona los valores distintos
select distinct "Departure_Airport" 
from flight_data fd 
order by "Departure_Airport" 

-- ROW_NUMBER() OVER() crea un contador de 1,...,n
select row_number() OVER() as numberr, "Departure_Airport" 
from flight_data fd 
group by "Departure_Airport" 

-- CASE WHEN THEN END: realiza evaluaciones en base a ciertas condiciones y devuelve diferentes resultados.
select "Date", "Departure_Airport", 
case when "Temperature_Celsius"  < 10 then 'cold'
	 when "Temperature_Celsius"  > 25 then 'hot'
	 else 'standard'
end as category_temp
from flight_data fd 

-- EJEMPLO:
select "Departure_Airport", "Turbulence_Level" , count(*)
from flight_data fd 
where "Time" > '08:00' and "Time" < '12:00'
group by "Departure_Airport", "Turbulence_Level" 
order by "Departure_Airport",
		case 
		when "Turbulence_Level" like 'Low' then 1
		when "Turbulence_Level" like 'Medium' then 2
		when "Turbulence_Level" like 'High' then 3
	end
	
	
--MAS
	
select *, dense_rank() OVER(
	partition by "Departure_Airport" 
	order by "Temperature_Celsius"  ASC
) as ranked
from flight_data fd 

select *, dense_rank() OVER(
	partition by "Departure_Airport" 
	order by "Temperature_Celsius" DESC
) as ranked
from(
	select "Departure_Airport",  
	from flight_data fd 
	group by "Departure_Airport", 
) tabla
 


