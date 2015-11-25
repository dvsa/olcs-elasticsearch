#!/usr/bin/php
<?php

$json = file_get_contents( 'php://stdin' ) ;

$data = json_decode($json);
//var_dump($data);


foreach ($data->indices as $index => $indexData) {
    $indices[$index] = $indexData;
}

ksort($indices);

echo "====================================================\n";
printf(
    "%-20s %10s %20s\n",
    'INDEX',
    'COUNT',
    'SIZE'
);
echo "====================================================\n";
foreach ($indices as $index => $indexData) {
    printf(
        "%-20s %10s %20s\n",
        $index,
        number_format($indexData->primaries->docs->count),
        number_format($indexData->primaries->store->size_in_bytes)
    );
}


