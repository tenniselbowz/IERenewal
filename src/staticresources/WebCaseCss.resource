
	/*
	 * HTML5 Boilerplate
	 *
	 * What follows is the result of much research on cross-browser styling.
	 * Credit left inline and big thanks to Nicolas Gallagher, Jonathan Neal,
	 * Kroc Camen, and the H5BP dev community and team.
	 */
	
	/* ==========================================================================
	   Base styles: opinionated defaults
	   ========================================================================== */
	
	html, button, input, select, textarea {
		color: #222;
	}
	body {
		font-size: 1em;
		line-height: 1.4em;
	}
	
	
	/*
	 * Remove text-shadow in selection highlight: h5bp.com/i
	 * These selection rule sets have to be separate.
	 * Customize the background color to match your design.
	 */
	
	
	/*
	 * A better looking default horizontal rule
	 */
	
	hr {
		display: block;
		height: 1px;
		border: 0;
		border-top: 1px solid #ccc;
		margin: 1em 0;
		padding: 0;
	}
	/*
	 * Remove the gap between images and the bottom of their containers: h5bp.com/i/440
	 */
	
	img {
		vertical-align: middle;
	}
	/*
	 * Remove default fieldset styles.
	 */
	
	fieldset {
		border: 0;
		margin: 0;
		padding: 0;
	}
	/*
	 * Allow only vertical resizing of textareas.
	 */
	
	textarea {
		resize: vertical;
	}
	
    /* ==========================================================================
	   Chrome Frame prompt
	   ========================================================================== */
	
	.chromeframe {
		margin: 0.2em 0;
		background: #ccc;
		color: #000;
		padding: 0.2em 0;
	}
	/* ==========================================================================
	   Author's custom styles
	   ========================================================================== */


	html, body {
		border: 0;
		margin: 0;
		padding: 0;
	}
	body {
		font-family: Verdana, Geneva, sans-serif;
		font-size: 12px;
		font-weight: 400;
		margin: 0px;
		padding: 0px;
		background-color: #FFF;
		color: #767676;
		font-style: normal;
		line-height: 1.5em;
	}
	
	/* LINKS */
	
	a {
		color: #0A7BC1;
	}
	a:link {
		text-decoration: underline;
		color: #0A7BC1;
	}
	a:visited {
		text-decoration: underline;
		color: #0A7BC1;
	}
	a:focus {
		outline: none;
	}
	a:hover {
		text-decoration: none;
		color: #555152;
	}
	a:active, a:focus {
		outline: none;
	 ie-dummy: expression(this.hideFocus=true);  /*IE blue outline on click hide */
	}
	/* HEADINGS */
	
	h1, h2, h3, h4, h5, h6 {
		margin: 0px 0px 5px;
		padding-bottom: 5px;
		display: block;
		line-height: 1em;
	}
	h1 {
		font-size: 32px;
		padding: 0px;
		font-family: 'Rokkitt', serif;
		font-weight: 400;
		color: #555152;
	}
	h2 {
		font-size: 24px;
		padding: 0px;
		font-family: 'Rokkitt', serif;
		font-weight: 400;
		line-height: 30px;
	}
	h3 {
		font-size: 20px;
		font-family: 'Rokkitt', serif;
		letter-spacing: 0em;
		color: #555152;
		font-weight: 400;
		display: block;
		padding-top: 0px;
		padding-right: 0px;
		padding-bottom: 0px;
		padding-left: 0px;
	}
	h4 {
		font-size: 18px;
		padding: 0px;
		font-family: 'Rokkitt', serif;
		color: #004F8D;
		font-weight: 400;
	}
	h5 {
		font-size: 16px;
		padding: 0px;
		font-family: 'Rokkitt', serif;
		color: #333;
	}
	h6 {
		font-size: 16px;
		padding: 0px;
		font-family: 'Rokkitt', serif;
		color: #333;
	}
	.greenText {
		color: #4C8F0F;
	}
	.blueText {
		color: #4383C5;
	}
	p {
		margin-bottom: 8px;
		margin-top: 0px;
	}
	.left {
		float: left;
	}
	.right {
		float: right;
	}
	.image-left {
		float: left;
		padding-right: 10px;
		padding-bottom: 5px;
		padding-top: 5px;
	}
	.image-right {
		float: right;
		padding-left: 10px;
		padding-bottom: 5px;
	}
	.image-frameborder {
		padding: 8px;
		background-color: #EFEEE9;
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		border-top: 1px solid #DFDEDB;
		border-right: 1px solid #C0BFBC;
		border-bottom: 1px solid #C0BFBC;
		border-left: 1px solid #DFDEDB;
		margin-top: 5px;
		margin-bottom: 5px;
	}
	.left-frameborder {
		padding: 8px;
		background-color: #F4F3EF;
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		border-top: 1px solid #DFDEDB;
		border-right: 1px solid #C0BFBC;
		border-bottom: 1px solid #C0BFBC;
		border-left: 1px solid #DFDEDB;
		margin-top: 5px;
		margin-right: 10px;
		margin-bottom: 5px;
		float: left;
	}
	.right-frameborder {
		padding: 8px;
		background-color: #F4F3EF;
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		border-top: 1px solid #DFDEDB;
		border-right: 1px solid #C0BFBC;
		border-bottom: 1px solid #C0BFBC;
		border-left: 1px solid #DFDEDB;
		margin-top: 5px;
		margin-bottom: 5px;
		float: right;
		margin-left: 10px;
	}
	
	/* IE6 Whitespace Bug fix*/
	
	ul li {
		display: inline;
	}
	/* ie fix image border */
	
	a img {
		border: 0px;
	}
	/* Main Menu Current Pages Set */
	body#bhome a#home, body#babout a#about, body#bemployment a#employment, body#bpress a#press, body#bsitemap a#sitemap, body#bproducts a#products, body#bcontactpage a#contactpage {
		background: #EEEEE8;
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		color: #555152;
		border-top-style: none;
		border-right-style: none;
		border-bottom-style: none;
		border-left-style: none;
	}
	/* NavVertical Current Pages Set */
	body#bnavprod a#navprod, body#bnavdesign a#navdesign, body#bnavequest a#navequest, body#bnavbim a#navbim, body#bnavresource a#navresource, body#bnavseismic a#navseismic, body#bnavtraining a#navtraining {
		color: #000;
		text-decoration: none;
		background-image: url(../images/icons/blueArrowTone.gif);
		background-repeat: no-repeat;
		background-position: left top;
	}
	/* SubNavVertical Current Pages Set */
	body#bchillers a#chillers, body#bah a#ah, body#bwshp a#wshp, body#brooftop a#rooftop, body#bfc a#fc, body#bmcp a#mcp, body#bis a#is, body#bcoils a#coils, body#bscs a#scs, body#buv a#uv, body#bptac a#ptac, body#bcu a#cu, body#bcontrols a#controls, body#bvav a#vav {
		color: #0A7BC1;
		background-image: url(../images/icons/square-dark.gif);
		background-repeat: no-repeat;
		background-position: 12px 8px;
	}
	#headerWrap {
		margin-bottom: 0px;
		padding: 0px;
		margin-right: auto;
		margin-left: auto;
		margin-top: 0px;
		position: relative;
		background-color: #FFF;
		clear: both;
	}

	
	#header {
		margin-bottom: 0px;
		padding: 0px;
		margin-right: auto;
		margin-left: auto;
		margin-top: 0px;
		width: 960px;
		height: 55px;
		position: relative;
		background-color: #FFF;
	}
	#header img {
		padding-left: 174px;
	}
	#header #content {
		width: 760px;
		float: right;
		padding-top: 40px;
	}
	#bannerWrap {
		padding: 0px;
		margin-top: 0px;
		margin-right: auto;
		margin-bottom: 0px;
		margin-left: auto;
		display: block;
		background-color: #FFF;
		clear: both;
		background-image: url(../images/bgBannerWrap.gif);
		background-repeat: repeat-x;
		background-position: left bottom;
	}
	#banner {
		padding: 0px;
		margin-top: 0px;
		margin-right: auto;
		margin-bottom: 0px;
		margin-left: auto;
		display: block;
		height: 340px;
		width: 960px;
	}
	#videoWrap {
		padding: 0px;
		float: right;
		background-repeat: repeat-y;
		background-position: left top;
		height: 340px;
		width: 786px;
		background-image: url(../video.files/videoContainer.gif);
	}
	#banner #apLeave {
		padding: 180px 0px 0px;
		width: 240px;
		position: absolute;
		z-index: 2;
	}
	#bannerSubs {
		padding: 0px;
		margin-top: 0px;
		margin-right: auto;
		margin-bottom: 0px;
		margin-left: auto;
		display: block;
		height: 160px;
		width: 960px;
	}
	#bannerSubs #apSlogan {
		position: absolute;
		z-index: 1;
		padding: 15px;
		text-align: right;
		width: 930px;
	}
	#bannerSubs #apSlogan h1 {
		font-size: 24px;
		color: #F4F3EF;
		border-top-style: none;
		border-right-style: none;
		border-bottom-style: none;
		border-left-style: none;
	}
	#bannerSubs #apSlogan h2 {
		color: #383838;
		font-size: 18px;
	}
	#wrapper {
		margin: 0 auto;
		padding: 0;
		display: block;
		border-bottom-width: 1px;
		border-bottom-style: solid;
		border-bottom-color: #D5D6D0;
	}
	#container {
		width: 960px;
		margin: 0 auto;
		padding: 0px;
		background-color: #FFF;
		background-image: url(../images/border-leftside.gif);
		background-repeat: repeat-y;
		background-position: left top;
	}
	/* end */
	
	
	#colMain {
		padding: 0px;
		margin: 0px;
		float: right;
		width: 785px;
		border-left-width: 1px;
		border-left-style: none;
		border-left-color: #D5D6D0;
		font-size: 1.1em;
	}
	#colMain h1 {
		text-shadow: none;
		text-decoration: none;
		color: #555152;
		display: block;
		padding-bottom: 2px;
		margin-bottom: 12px;
		border-bottom-width: 1px;
		border-bottom-style: solid;
		border-bottom-color: #D5D6D0;
	}
	#colSide {
		list-style-type: none;
		margin: 0;
		padding: 20px 0px;
		width: 174px;
		vertical-align: top;
		font-size: 12px;
	}
	#colSide p {
		padding: 5px 10px 5px 0px;
	}
	#colSide h1 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 1.3em;
		line-height: 1.3em;
		padding: 5px 5px 5px 0px;
		color: #EEEEE4;
		font-style: normal;
		font-weight: 400;
		text-transform: uppercase;
		background-color: #8C8C8C;
		margin: 0px;
	}
	#colSide h4 {
		padding-right: 5px;
		font-size: 20px;
		margin-bottom: 20px;
	}
	#content {
		padding: 0px 0px 10px 25px;
	}
	#content .graybox {
		display: block;
		padding: 6px 0px 10px;
		border: 1px solid #E2E4E1;
		-moz-border-radius: 6px;
		-webkit-border-radius: 6px;
		border-radius: 6px;
		background-color: #F4F3EF;
		background-image: url(../images/bgGraybox.png);
		background-repeat: no-repeat;
		background-position: left top;
		margin-bottom: 10px;
	}
	#content .graybox p {
		padding-right: 10px;
		padding-left: 10px;
		color: #6B6B6B;
		font-family: Arial, Helvetica, sans-serif;
	}
	#content .graybox h1 {
		color: #004FA9;
		font-size: 19px;
		border-left-width: 8px;
		border-left-style: solid;
		border-left-color: #E4E2DC;
		padding-left: 10px;
		font-weight: 400;
		padding-top: 3px;
		padding-right: 10px;
		padding-bottom: 2px;
		line-height: 1em;
	}
	#content strong {
		color: #444;
		font-weight: bold;
	}
	.full-width {
		margin-top: 5px;
		margin-bottom: 5px;
		background-color: #FFF;
		overflow: hidden;
	}
	.one-half {
		width: 371px;
		display: block;
		margin-right: 15px;
		margin-bottom: 15px;
		float: left;
	}
	.one-third {
		width: 240px;
		display: block;
		float: left;
		margin-right: 19px;
		margin-bottom: 15px;
	}
	.one-third .img-border {
		padding: 5px;
		margin-bottom: 10px;
		background-color: #F4F3EF;
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		width: 228px;
		height: 136px;
		border-top: 1px solid #DFDEDB;
		border-right: 1px solid #C0BFBC;
		border-bottom: 1px solid #C0BFBC;
		border-left: 1px solid #DFDEDB;
	}
	.two-thirds {
		width: 490px;
		display: block;
		float: left;
		margin-right: 18px;
		padding-right: 10px;
	}
	.two-thirds h5 {
		margin-bottom: 10px;
	}
	.two-thirds h5 span {
		color: #FFFFFF;
		background-color: #28AFED;
		padding-top: 2px;
		padding-right: 10px;
		padding-bottom: 1px;
		padding-left: 10px;
		line-height: 1.6em;
		border: 1px solid #E4E2DC;
	}
	.one-fourth {
		width: 175px;
		float: left;
		margin-right: 20px;
		margin-bottom: 5px;
		font-size: 12px;
	}
	.one-fourth .products {
		padding: 5px;
		margin-bottom: 5px;
		background-color: #F4F3EF;
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		width: 162px;
		height: 100px;
		border: 1px solid #DFDEDB;
	}
	.sales{
		width: 170px;
		margin-right: 10px;
	}
	
	.three-fourths {
		width: 555px;
		display: block;
		margin-bottom: 10px;
	}
	.last {
		margin-right: 0!important;
	}
	.caption {
		width: 175px;
		float: right;
		margin-left: 20px;
		margin-bottom: 5px;
		font-size: 12px;
		border-left: 1px solid #DFDEDB;
		padding-left:10px;
	}
	.container-250 {
		padding: 0px;
		width: 290px;
		margin-left: 20px;
		margin-bottom: 5px;
	}
	.solutions {
		width: 300px;
	 text-align:right  display: block;
		margin-right: 5px;
		margin-bottom: 10px;
		float: right;
		text-align: right;
	}
	.dates {
		display: block;
		font-size: 10px;
		background-color: #F3F2ED;
		height: 9px;
		margin-bottom: 10px;
		color: #000;
		padding-left: 5px;
		font-family: Verdana, Geneva, sans-serif;
	}
	.black-links a {
		text-decoration: none;
		color: #232323;
	}
	.black-links a:hover {
		text-decoration: underline;
		color: #000000;
	}
	/* Bullets */
	ul.bullets {
		list-style: none;
		margin: 0px;
		line-height: 20px;
		display: block;
		padding-top: 0px;
		padding-bottom: 10px;
		padding-left: 20px;
		padding-right: 5px;
		font-weight: normal;
	}
	ul.bulletsClose {
		list-style: none;
		margin: 0px;
		line-height: 20px;
		display: block;
		padding-top: 0px;
		padding-bottom: 5px;
		padding-left: 0px;
		padding-right: 0px;
		font-weight: normal;
	}
	ul.arrow li {
		list-style: none;
		background: url(../images/icons/arrow_bullet.png) no-repeat 0 11px transparent;
		display: block;
		padding-top: 5px;
		padding-right: 5px;
		padding-bottom: 0px;
		padding-left: 15px;
	}
	ul.black li {
		list-style: none;
		background: transparent url(../images/icons/black_bullet.png) no-repeat 0 11px;
		display: block;
		padding-top: 5px;
		padding-right: 5px;
		padding-bottom: 0px;
		padding-left: 15px;
	}
	ul.black-sm li {
		list-style: none;
		display: block;
		padding-top: 5px;
		padding-right: 5px;
		padding-bottom: 0px;
		padding-left: 12px;
		background-color: transparent;
		background-image: url(../images/icons/black-sm-bullet.gif);
		background-repeat: no-repeat;
		background-position: 0px 12px;
	}
	ul.outline li {
		list-style: none;
		display: block;
		padding-top: 5px;
		padding-right: 5px;
		padding-bottom: 0px;
		padding-left: 12px;
		background-color: transparent;
		background-image: url(../images/icons/outline-bullet.gif);
		background-repeat: no-repeat;
		background-position: 0px 12px;
	}
	ul.red li {
		list-style: none;
		background: url(../images/icons/red_bullet.png) no-repeat 0 11px transparent;
		display: block;
		padding-top: 5px;
		padding-right: 5px;
		padding-bottom: 0px;
		padding-left: 15px;
	}
	ul.blue li {
		list-style: none;
		padding: 5px 5px 0px 20px;
		background: url(../images/icons/blue_bullet.png) no-repeat 0 11px transparent;
		display: block;
	}
	ul.green li {
		list-style: none;
		padding: 5px 5px 0px 20px;
		background: url(../images/icons/green_bullet.png) no-repeat 0 11px transparent;
		display: block;
	}
	ul.square li {
		list-style: none;
		padding: 5px 5px 0px 20px;
		background: url(../images/icons/square_bullet.png) no-repeat 0 11px transparent;
		display: block;
	}
	ul.no-icons li {
		list-style: none;
		display: block;
		background-image: none;
		margin: 0px;
		padding-top: 5px;
		padding-right: 0px;
		padding-bottom: 5px;
		padding-left: 0px;
	}
	ul.document {
		list-style: none;
		margin: 0px;
		line-height: 18px;
		font-size: 11px;
		display: block;
		background-color: #FFF;
		padding-top: 0px;
		padding-bottom: 10px;
		padding-left: 0px;
		padding-right: 0px;
		font-weight: normal;
		font-family: Arial, Helvetica, sans-serif;
	}
	ul.document li {
		list-style: none;
		padding: 5px 5px 0px 20px;
		background: transparent url(../images/16x16/document.gif) no-repeat 0px 6px;
		display: block;
		line-height: 1.5em;
		margin-bottom: 5px;
	}
	ul.document li strong {
		list-style: none;
		padding-right: 5px;
		font-style: italic;
		font-size: 10px;
		font-family: Arial, Helvetica, sans-serif;
		font-weight: normal;
	}
	 /* end */

	
	.clearer {
	 font-size: 0px;
	 line-height: 0px;
	 margin: 0px;
	 padding: 0px;
	 clear: both;
	 border-top-style: none;
	 border-right-style: none;
	 border-bottom-style: none;
	 border-left-style: none;
	 font-family: Verdana, Geneva, sans-serif;
	 height: 1px;
	}
	.hr_line {
		max-width: 940px;
		border-bottom: 1px solid #D5D6D0;
		clear: both;
		height: 1px;
		margin-top: 5px;
		margin-bottom: 20px;
		display: block;
	}
	.botBorder {
		border-bottom-width: 1px;
		border-bottom-style: solid;
		border-bottom-color: #D5D6D0;
		margin-bottom: 15px;
		padding-bottom: 8px;
	}
	#readmore {
		padding-top: 2px;
		padding-bottom: 3px;
		display: block;
	}
	#readmore a:link, #readmore a:visited {
		background: #EEEEE9;
		color: #666;
		font-size: 11px;
		padding: 4px 8px;
		text-decoration: none;
		display: table;
		margin-top: 5px;
		-moz-border-radius: 5px;
		-webkit-border-radius: 5px;
		border-radius: 5px;
		border: 1px solid #D7D7D1;
		margin-right: 10px;
	}
	#readmore a:hover, #readmore a:active {
		background-color: #0A7BC1;
		color: #FFF;
		background-image: none;
		
		
		}
	#myButton {
		padding-top: 2px;
		padding-bottom: 3px;
		display: block;
	}
	#myButton  a:link, #myButton  a:visited {
		background: #EEEEE9;
		color: #666;
		font-size: 12px;
		padding: 4px 8px;
		text-decoration: none;
		display: table;
		margin-top: 5px;
		-moz-border-radius: 5px;
		-webkit-border-radius: 5px;
		border-radius: 5px;
		border: 1px solid #D7D7D1;
		margin-right: 10px;
		font-family: Verdana, Geneva, sans-serif;
	}
	#myButton  a:hover, #myButton  a:active {
		background-color: #0A7BC1;
		color: #FFF;
		background-image: none;
		
		/* end */
		

	}
	.news-date {
		font-size: 11px;
		line-height: 20px;
		color: #666;
		background-color: #F1F0EB;
		display: block;
		margin-bottom: 10px;
		padding-top: 2px;
		padding-right: 0px;
		padding-bottom: 2px;
		padding-left: 10px;
	}
	#footer {
		margin-top: 0px;
		width: 760px;
		margin-right: auto;
		margin-bottom: 30px;
		margin-left: auto;
		text-align: left;
		position: relative;
		font-family: Arial, Helvetica, sans-serif;
		padding-top: 10px;
		padding-right: 0px;
		padding-bottom: 10px;
		padding-left: 200px;
		font-size: 12px;
	}
	#footer p {
		padding-bottom: 5px;
		margin: 0px;
	}
	#footer h5 {
		display: block;
		vertical-align: middle;
		margin-bottom: 8px;
		line-height: 18px;
	}
	#footer h5 img {
		padding-right: 4px;
		vertical-align: top;
		padding-bottom: 2px;
	}
	#footer a:link, #footer a:visited {
		text-decoration: none;
		color: #0A7BC1;
	}
	#footer a:hover, #footer a:active {
		color: #093;
		text-decoration: underline;
	}
	
	.cfg-clear{
	clear:both;
}
.cfg-contactform{
	width:400px;
	margin:auto;
	float:left;
}

.ui-datepicker{
	font-size:9pt !important;
}

.cfg-element-container{
	clear:both;
}
.cfg-element-set{
	margin-bottom:16px;
}

.cfg-option-set::after{ /* restore margin bottom when elements are floating */
	content: ".";
	display: block;
	height: 0;
	clear: both;
	visibility: hidden;
}
.cfg-label{
	display:block;
	margin-right:10px;
}

.cfg-paragraph{
	margin-bottom:1px; 
}
.captcha_container{
	margin-top:2px;
}

.cfg-captcha-input{
	width:110px;
}

.cfg-captcha-img{
	border:1px solid #dcdcdc;
	-webkit-border-radius:4px;
	-moz-border-radius:4px;
	border-radius:4px;
	
	margin-bottom:1px; /* Opera */
}

.cfg-captcha-refresh{
	margin-bottom:8px;
	cursor:pointer;
}
.cfg-submit{
	cursor:pointer;
	padding:8px 4px;
	-webkit-border-radius:5px;
	-moz-border-radius:5px;
	border-radius:5px;
	border-width: 1px;
	border-style: solid;
	font-family: Arial;
	font-weight: bold;
	font-size: 14px;
	margin-left: 0;
	color: #555555;
	background-color: #f1f1f1;
	border-color: #cccccc;

}

.cfg-required{
	color:#990000;
	font-family:Arial, Helvetica, sans-serif;
}

.cfg-uploadsuccess-container{
	margin-top:10px;
	font-family:Verdana, Geneva, sans-serif;
	font-size:11px;
}
.cfg-deleteupload{
	color:#ff0033;
	margin-left:10px;
	cursor:pointer;
}
.cfg-deleteupload:hover{
	text-decoration:underline;
}

.cfg-loading{
	display:none;
	background:url('../img/loading.gif') no-repeat 0 1px;
	padding-left:20px;
	font-family:Arial, Helvetica, sans-serif;
	font-size:16px;
}

.cfg-errormessage, .cfg-validationmessage{
	font-family:Verdana, Geneva, sans-serif;
	font-size:12px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
	border-radius:3px;
}

.cfg-errormessage{
	display:none;
	margin:4px 0;
	width:260px;
}

.cfg-validationmessage{
	width:360px;
	margin-bottom:16px;
	padding:10px 6px;
}

.cfg-option-content input[type=radio], .cfg-option-content input[type=checkbox]{
	margin-right:2px;
}



.cfg-label{
	font-family:'Verdana';
	font-weight:normal;
	font-style:normal;
	font-size:13px;
}

.cfg-element-content input[type="text"], .cfg-element-content textarea, .cfg-element-content select, .cfg-option-content{
	font-family:Verdana;
	font-weight:normal;
	font-style:normal;
	font-size:12px;
	color:#000000;
}

.cfg-element-content input[type="text"], .cfg-element-content textarea{
	padding:2px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
	border-radius:3px;
	border-width:1px;
	border-style:solid;
	border-color:#dcdcdc;
}

#cfg-element-8-1{
	font-family:Arial;
	font-weight:bold;
	font-size:36px;
	color:#26ADE4;
}

#cfg-element-8-2-paragraph{
	font-family:Verdana;
	font-weight:normal;
	font-size:14px;
	color:#000000;
	width:300px;
}

#cfg-element-8-2{
	font-family:Verdana;
	font-weight:normal;
	font-size:14px;
	color:#000000;
	width:300px;
}

#cfg-element-8-6-paragraph{
	font-family:Verdana;
	font-weight:normal;
	font-size:12px;
	color:#a81a32;
	width:300px;
}

#cfg-element-8-6{
	font-family:Verdana;
	font-weight:normal;
	font-size:12px;
	color:#a81a32;
	width:300px;
}

#cfg-element-8-7-label{
	font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;
}

#cfg-element-8-7{
	width:220px;
}

#cfg-element-8-8-label{
	font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;
}

#cfg-element-8-8{
	width:220px;
}

#cfg-element-8-9-label{
	font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;

}

#cfg-element-8-9{
	width:220px;
}

#cfg-element-8-10-label{
	font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;

}

#cfg-element-8-10{
	width:220px;
}

#cfg-element-8-11-label{
		font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;

}

#cfg-element-8-11{
	width:220px;
}

#cfg-element-8-12-label{
	font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;

}

#cfg-element-8-13-label{
	font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;

}

#cfg-element-8-13{
	width:220px;
}

#cfg-element-8-14-label{
		font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;

}

#cfg-element-8-14{
	width:220px;
}

#cfg-element-8-3-label{
		font-family: Verdana, Geneva, sans-serif;
	font-weight: normal;
	font-style: normal;
	font-size: 14px;
	color: #666666;

}

#cfg-element-8-3{
	width:220px;
}

#cfg-element-8-5{
	width:200px;
	border-width:1px;
	border-style:solid;
	font-family:Arial;
	font-weight:bold;
	font-size:20px;
	margin-left:0;
	color:#555555;
	background-color:#f1f1f1;
	border-color:#cccccc;
}

.cfg-validationmessage{
	background-color:#00b700;
	color:#fff;
	padding:5px 7px;
}

.cfg-errormessage{
	background-color:#FF0000;
	color:#fff;
	padding:5px 7px;
}
