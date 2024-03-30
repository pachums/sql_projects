SELECT
  *
FROM ML.PREDICT(MODEL   `project_name.dataset_name.model_name`, (
SELECT
  FECHA_INICIO_NOLAB,
  CAST(GOS_COD_SEXO AS STRING) sexo,
  DIASCOT_180
  MAS_VARIABLES
FROM
  `sepe-ml.supertramos_v0.supertramos_v0_insc`
WHERE
  FECHA_inicio_NOLAB > '2019-10-31'
  AND FECHA_INICIO_NOLAB < '2020-04-30'
  AND NUM_NOLAB <> 0)) 
  WHERE DIASCOT_180 >0;
