CREATE TABLE IF NOT EXISTS `elastic_updates` (
  `id` VARCHAR(32) NOT NULL,
  `index_name` VARCHAR(20) NULL,
  `update_time_started` INT NULL,
  `update_time_ended` INT NULL,
  PRIMARY KEY (`id`)
    )
ENGINE = InnoDB;


insert into elastic_updates (`id`,`index_name`,`update_time_started`,`update_time_ended`) values
       (0,'application',0,0),
       (1,'case',0,0),
       (2,'licence',0,0),
       (3,'psv_disc',0,0),
       (4,'vehicle_current',0,0),
       (5,'vehicle_removed',0,0);
