update elastic_update set update_time_started=unix_timestamp(now()) where index_name='case';
