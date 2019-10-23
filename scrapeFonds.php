<?php

$output = '';

//get first page
$page = 1;
$fonds = get_fonds_url($page);
$last_page = $fonds['last_page'];
$output .= $fonds['output'];

//get remaining pages
for($i = $page + 1; $i <= $last_page ; $i++) {
        $fonds = get_fonds_url($i);
        $output .= $fonds['output'];
}

file_put_contents('fonds.txt', $output);

/***** helper functions *****/
function get_fonds_url($page = 1) {
        $holdings_url  = 'https://discoverarchives.library.utoronto.ca/index.php/repository/holdings/id/38836?page=' . $page;

        $contents = file_get_contents_curl($holdings_url);
        $json_decoded = json_decode($contents, TRUE);

        $current_page = $json_decoded['currentPage'];
        $last_page = $json_decoded['lastPage'];
        $output = '';

        foreach($json_decoded['results'] as $fonds) {
                $fonds_url = basename($fonds['url']);
                $output .= $fonds_url . PHP_EOL;
        }

        return array('output' => $output, 'current_page' => $current_page, 'last_page' => $last_page);
}

function file_get_contents_curl($url) {
    $ch = curl_init();

    curl_setopt($ch, CURLOPT_AUTOREFERER, TRUE);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, TRUE);

    $data = curl_exec($ch);
    curl_close($ch);

    return $data;
}
