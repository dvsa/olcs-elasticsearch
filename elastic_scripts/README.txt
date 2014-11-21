This project contains the ElasticSearch scripts necessary to load data from an
OLCS MySQL Database schema.

Assumptions:
1. The database is running on the same machine as the ElaticSearch instance.
This can be changed in configuration.
2. The database schema name is that defined in the River scripts. Thics can be
changed in config.

Current indices defined in the following directories:
1. vehicles - This contains the definitions for psv_discs, vehicles_and_goods_discs and vehicles_and_goods_discs_removed
2. applications  
3. cases  
4. licences  


Each directory contains 4 scripts:
1. Index creation
2. Index Deletion
3. River creation
4. River Deletion

CREATE AN INDEX STEPS - intention is that you run the scripts in this order

- Index Creation
- River Creation

When the river has completed (test with viewRiverStates.sh), run

- River Deletion

REBUILD INDEX STEPS - If you want to re-build the index from scratch:
1. Make sure the river is not running - Run the river deletion script if needs
be.
2. Run Index Deletion.
3. Follow CREATE AN INDEX STEPS again.

NB
For the vehicle index vehicles_and_goods_discs there needed to be an additional index creating for delta performance:

create index idx_vhl_removal on licence_vehicle(removal_date);
