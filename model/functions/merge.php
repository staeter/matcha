<?php
	function resize($in, $width, $height) {
		$new_image = imagecreatetruecolor($width, $height);

		//make sure the transparency information is saved
		imagealphablending($new_image, false);
		imagesavealpha($new_image, true);

		//copy in a new size and return
		imagecopyresampled($new_image, $in, 0, 0, 0, 0, $width, $height, imagesx($in), imagesy($in));
		return $new_image;
	}

	function merge($picture_path, $filter_path, $out_path) {
		//create img objects, getting picture's dimentions and resising filter
	    $picture = imagecreatefrompng($picture_path);
		$width = imagesx($picture);
		$height = imagesy($picture);
	    $filter = resize(imagecreatefrompng($filter_path), $width, $height);

		//create dest
	    $dest_image = imagecreatetruecolor($width, $height);

	    //make sure the transparency information is saved
	    imagesavealpha($dest_image, true);

	    //create a fully transparent background (127 means fully transparent)
	    $trans_background = imagecolorallocatealpha($dest_image, 0, 0, 0, 127);

	    //fill the image with a transparent background
	    imagefill($dest_image, 0, 0, $trans_background);

	    //copy each png file on top of the destination (result) png
	    imagecopy($dest_image, $picture, 0, 0, 0, 0, $width, $height);
	    imagecopy($dest_image, $filter, 0, 0, 0, 0, $width, $height);

	    //save img
	    imagepng($dest_image, $out_path);
	}

	// merge("../../data/tmp/up0.png", "../../data/filters/1.png", "../../data/tmp/up0.png");

    // imagedestroy($dest_image);
?>
