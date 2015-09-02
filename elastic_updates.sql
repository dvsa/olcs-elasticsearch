CREATE TABLE IF NOT EXISTS `elastic_update` (
  `id` VARCHAR(32) NOT NULL,
  `index_name` VARCHAR(20) NULL,
  `previous_runtime` INT NULL,
  `runtime` INT NULL,
  PRIMARY KEY (`id`)
    )
ENGINE = InnoDB;


insert into elastic_update (`id`,`index_name`,`previous_runtime`,`runtime`) values
       (0,'application',0,0),
       (1,'case',0,0),
       (2,'licence',0,0),
       (3,'psv_disc',0,0),
       (4,'vehicle_current',0,0),
       (5,'vehicle_removed',0,0);
