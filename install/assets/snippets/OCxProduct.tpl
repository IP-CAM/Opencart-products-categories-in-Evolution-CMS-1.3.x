/**
     * OCxProduct 
     *
	 * Display Open Cart products in Evolution CMS
     *
     * @author      Author: Nicola Lambathakis http://www.tattoocms.it/
     * @version 1.9.1
     * @internal	@modx_category OCx
     * @license 	http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 */

<?php
/**
    OCxProduct 1.9.1
    Sample call
[[OCxProduct? &id=`48,49` &opencartTpl=`opencartTpl` &fetchimages=`0` &orderby=`price` &orderdir=`DESC` &store_dir=`assets/images/ocx`]]
*/

/*define snippet params*/
$opencartTpl = (isset($opencartTpl)) ? $opencartTpl : 'opencartTpl';
$trim = (isset($trim)) ? $trim : '200';
$orderdir = (isset($orderdir)) ? $orderdir : 'DESC';
$orderby = (isset($orderby)) ? $orderby : 'product_id';
$fetchimages = (isset($fetchimages)) ? $fetchimages : '0'; 
$store_dir = (isset($store_dir)) ? $store_dir : 'assets/images/ocx';
$store_dir_type = (isset($store_dir_type)) ? $store_dir_type : 'relative';
$overwrite = (isset($overwrite)) ? $overwrite : 'false';
$pref = (isset($pref)) ? $pref : 'false';
$debug = (isset($debug)) ? $debug : 'true';
$convert = (isset($convert)) ? $convert : '0';
$charset = (isset($charset)) ? $charset : 'ISO-8859-1';
$trim = (isset($trim)) ? $trim : '200';
$noResults = (isset($trim)) ? $trim : 'No product found';

include_once(MODX_BASE_PATH . 'assets/snippets/ocx/ocx.functions.php');  

$db_server = new mysqli($oc_db_hostname,$oc_db_username,$oc_db_password,$oc_db_database); 
if (mysqli_connect_errno()) { 
    printf("Can't connect to MySQL Server. Errorcode: %s\n", mysqli_connect_error()); 
    exit; 
} 
   

$result0 = mysqli_query($db_server, "SELECT DISTINCT 
oc_product.product_id, oc_product.status, oc_product.image, oc_product.price, oc_product.model, oc_product.quantity, oc_product.viewed, oc_product.isbn,oc_product_description.name,oc_product_description.description
FROM oc_product 
INNER JOIN oc_product_description ON oc_product.product_id=oc_product_description.product_id 
INNER JOIN oc_product_to_category ON oc_product_description.product_id = oc_product_to_category.product_id
WHERE oc_product.product_id IN ($id)
ORDER BY oc_product.$orderby $orderdir")
or die(mysqli_error($db_server)); if (!$result0) die ("Database access failed: " . mysqli_error());

if ( mysqli_num_rows( $result0 ) < 1 )
{
     echo" $noResults";
}
else
{
	
while($row0 = mysqli_fetch_array( $result0 )) {
	$id = $row0['product_id'];	  
	$image = $row0['image'];
	$price = sprintf('%0.2f', $row0['price']);
	$isbn = $row0['isbn'];
	$name = $row0['name'];
	$model = $row0['model'];
	$quantity = $row0['quantity'];
	$viewed = $row0['viewed'];
    $htmldescription = $row0['description'];
    $description = html_entity_decode($htmldescription);
	$flat_description = strip_tags($description);
	$short_description = substrwords($flat_description,$trim);
	$remote_image = "$oc_shop_url/$oc_image_folder$image";
	
	if($convert == '1') {
		$d1_image = mb_convert_encoding($image, 'HTML-ENTITIES', $charset);
		$d_image = html_entity_decode($d1_image);
	}
	else  {
	     $d_image = $image;
	}
	$remote_image = "$oc_shop_url/$oc_image_folder$d_image";
	if($fetchimages == '0') {
	$oc_image = $remote_image;
	}
	else 
	if($fetchimages == '1') {
	$oc_image = itg_fetch_image($remote_image, $store_dir, $store_dir_type, $overwrite, $pref, $debug);
    }
 // oc product special price
        $result4 = mysqli_query($db_server, "SELECT DISTINCT * FROM oc_product_special WHERE product_id IN ($id) GROUP BY product_id");
        while($row = mysqli_fetch_array( $result4)) {
            $spprice = sprintf('%0.2f', $row4['price']);
        }
		
		
 // oc product url alias for friendly urls link		
    $result5 = mysqli_query($db_server, "SELECT DISTINCT * FROM oc_url_alias WHERE query='product_id=$id'");
    while($row5 = mysqli_fetch_array( $result5 )) {
    $keyword = $row5['keyword'];
		}
		
// define the placeholders and set their values

$product_url = "$oc_shop_url/index.php?route=product/product&product_id=$id";
$product_alias_url = "$oc_shop_url/$keyword";
$buy_from_amazon = "http://www.$oc_amazon/dp/$isbn?tag=$oc_affiliate_amazon_tag";
		
// convert charset				
		if($convert == '1')
		{
		$d_name = mb_convert_encoding($name, 'HTML-ENTITIES', $charset);
		$d_short_description = mb_convert_encoding($short_description, 'HTML-ENTITIES', $charset);
		$d_description = mb_convert_encoding($description, 'HTML-ENTITIES', $charset);
		$d_product_alias_url = mb_convert_encoding($product_alias_url, 'HTML-ENTITIES', $charset);
		}	
		else {
		$d_name = $name;
		$d_short_description = $short_description;
		$d_description = $description;
		$d_product_alias_url = $product_alias_url;
		}		

// parse the chunk and replace the placeholder values.
// note that the values need to be in an array with the format placeholderName => placeholderValue
$values = array('ocimage' => $oc_image, 'ocremoteimage' => $oc_remoteimage, 'ocid' => $id, 'ocname' => $d_name, 'ocdescription' => $d_description, 'ocshort_description' => $d_short_description, 'ocprice' => $price, 'ocmodel' => $model,'ocquantity' => $quantity,'ocviewed' => $viewed, 'ocspprice' => $spprice, 'ocalias' => $keyword, 'ocshop_url' => $oc_shop_url, 'ocproduct_url' => $product_url, 'ocproduct_alias_url' => $d_product_alias_url, 'buy_from_amazon' => $buy_from_amazon);

$output =  $output . $modx->parseChunk($opencartTpl, $values, '[+', '+]');

	}
}//end while 'Get product IDs in right category'
mysqli_close($db_server);


return $output;