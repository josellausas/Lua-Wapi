/*
 * ZurApp Multiconcept App Showcase Template v1.0
 * Copyright 2015 8Guild.com
 * Theme Custom Scripts
 */
 /* ╔══╗╔═══╗╔╗╔╗╔══╗╔╗──╔══╗
  	║╔╗║║╔══╝║║║║╚╗╔╝║║──║╔╗╚╗
  	║╚╝║║║╔═╗║║║║─║║─║║──║║╚╗║
  	║╔╗║║║╚╗║║║║║─║║─║║──║║─║║
  	║╚╝║║╚═╝║║╚╝║╔╝╚╗║╚═╗║╚═╝║
  	╚══╝╚═══╝╚══╝╚══╝╚══╝╚═══╝
*/

jQuery(document).ready(function($) {
	'use strict';

	// Disable default link behavior for dummy links that have href='#'
	var $emptyLink = $('a[href=#]');
	$emptyLink.on('click', function(e){
		e.preventDefault();
	});

	// Dynamically adding classes to navbar on window scroll
	$(window).on('scroll', function(){
		var $navbar = $('.navbar-sticky');
    if ($(window).scrollTop() > 80) {
      $navbar.addClass('stuck');
    } else {
    	$navbar.removeClass('stuck');
    }
	});

	// Animated Scroll to Top Button
	var $scrollTop = $('.scroll-to-top-btn');
	if ($scrollTop.length > 0) {
		$(window).on('scroll', function(){
	    if ($(window).scrollTop() > 600) {
	      $scrollTop.addClass('visible');
	    } else {
	      $scrollTop.removeClass('visible');
	    }
		});
		$scrollTop.on('click', function(e){
			e.preventDefault();
			$('html').velocity("scroll", { offset: 0, duration: 1000, easing:'easeOutExpo', mobileHA: false });
		});
	};

	// Smooth scroll to element
	var $scrollTo = $('.scroll-to');
	$scrollTo.on('click', function(event){
		var $elemOffsetTop = $(this).data('offset-top');
		$('html').velocity("scroll", { offset:$(this.hash).offset().top-$elemOffsetTop, duration: 1000, easing:'easeOutExpo', mobileHA: false});
		event.preventDefault();
	});


	// Toggle Mobile Navigation
	var $navToggle = $('.nav-toggle', '.navbar');
	$navToggle.on('click', function(){
		$(this).toggleClass('active').parent().find('.main-navigation').toggleClass('expanded');;
	});

	// Mobile Submenu
	var $hasSubmenu = $('.has-submenu > a', '.main-navigation');
	$hasSubmenu.on('click', function(){
		$(this).parent().toggleClass('active').find('.submenu').toggleClass('expanded');;
	});

	// Tooltips
	var $tooltip = $('[data-toggle="tooltip"]');
	if ( $tooltip.length > 0 ) {
		$tooltip.tooltip();
	}

	// Featured Tabs Autoswitching
	var $autoTab = $('.featured-tabs .nav-tabs[data-autoswitch]');
	if($autoTab.length > 0) {
    var $changeInterval = $('.featured-tabs .nav-tabs').data('interval');
		var $tabCarousel = setInterval(function() {
      var $tabs = $('.featured-tabs .nav-tabs > li'),
          $active = $tabs.filter('.active'),
          $next = $active.next('li'),
          $toClick = $next.length ? $next.find('a') : $tabs.eq(0).find('a');

      $toClick.trigger('click');
	  }, $changeInterval);
	}

	// Device Carousel
	var $phoneCarousel = $( '.phone-carousel .inner' );
	if ( $phoneCarousel.length > 0 ) {
		$phoneCarousel.each( function () {
			var $parent = $(this).parents('.phone-carousel');

			var dataLoop 	 = $parent.data( 'loop' ),
					autoPlay   = $parent.data( 'autoplay' ),
					timeOut    = $parent.data( 'interval' );

			$( this ).owlCarousel( {
				items: 1,
				loop: dataLoop,
				margin: 0,
				nav: false,
				dots: true,
				navText: [ , ],
				autoplay: autoPlay,
				autoplayTimeout: timeOut,
				autoHeight: true
			} );
		} );
	}

	// Image Carousel
	var $imageCarousel = $( '.image-carousel .inner' );
	if ( $imageCarousel.length > 0 ) {
		$imageCarousel.each( function () {

			var dataLoop 	 = $( this ).parent().data( 'loop' ),
					autoPlay   = $( this ).parent().data( 'autoplay' ),
					timeOut    = $( this ).parent().data( 'interval' ),
					autoheight = $( this ).parent().data( 'autoheight' );

			$( this ).owlCarousel( {
				items: 1,
				loop: dataLoop,
				margin: 0,
				nav: true,
				dots: false,
				navText: [ , ],
				autoplay: autoPlay,
				autoplayTimeout: timeOut,
				autoHeight: autoheight
			} );
		} );
	}

	// Quotation Carousel
	var $quoteCarousel = $( '.quote-carousel .inner' );
	if ( $quoteCarousel.length > 0 ) {
		$quoteCarousel.each( function () {

			var dataLoop 	 = $( this ).parent().data( 'loop' ),
					autoPlay   = $( this ).parent().data( 'autoplay' ),
					timeOut    = $( this ).parent().data( 'interval' );

			$( this ).owlCarousel( {
				items: 1,
				loop: dataLoop,
				margin: 0,
				nav: false,
				dots: true,
				navText: [ , ],
				autoplay: autoPlay,
				autoplayTimeout: timeOut,
				autoHeight: true
			} );
		} );
	}

	// Clients Carousel
	var $clientCarousel = $( '.clients-carousel .inner' );
	if ( $clientCarousel.length > 0 ) {
		$clientCarousel.each( function () {

			var dataLoop 	 = $( this ).parent().data( 'loop' ),
					autoPlay = $( this ).parent().data( 'autoplay' ),
					timeOut = $( this ).parent().data( 'interval' );

			$( this ).owlCarousel( {
				loop: dataLoop,
				margin: 20,
				nav: false,
				dots: false,
				autoplay: autoPlay,
				autoplayTimeout: timeOut,
				responsiveClass: true,
				responsive: {
					0: { items: 2 },
					480: { items: 3 },
					700: { items: 4 },
					1000: { items: 5 },
					1200: { items: 6 },
					1330: {
						items: 6,
						margin: 60
					}
				}
			} );
		} );
	}

	// Gallery Popup
	var $gallItem = $( '.gallery-item' );
	if( $gallItem.length > 0 ) {
		$gallItem.magnificPopup( { 
		  type: 'image',
		  mainClass: 'mfp-fade',
		  gallery: {
		    enabled: true
		  },
		  removalDelay: 500,
		  image: {
		  	titleSrc: 'data-title'
		  }
		} );
	}

	// Video Popup
	var $videoBtn = $( '.video-popup-btn' );
	if( $videoBtn.length > 0 ) {
		$videoBtn.magnificPopup( { 
		  type: 'iframe',
		  mainClass: 'mfp-fade',
		  removalDelay: 500
		} );
	}

	// On window load functions
	$(window).on('load', function(){

		// Isotope Grid
		var $grid = $('.isotope-masonry-grid, .isotope-grid');
		if($grid.length > 0) {
		  $grid.isotope({
			  itemSelector: '.grid-item',
			  transitionDuration: '0.7s',
			  masonry: {
			    columnWidth: '.grid-sizer',
			    gutter: '.gutter-sizer'
			  }
		  });
		}

		// Filtering
		if($('.filter-grid').length > 0) {
		  var $filterGrid = $('.filter-grid');
			$('.nav-filters').on( 'click', 'a', function(e) {
				e.preventDefault();
				$('.nav-filters li').removeClass('active');
				$(this).parent().addClass('active');
			  var $filterValue = $(this).attr('data-filter');
			  $filterGrid.isotope({ filter: $filterValue });
			});
		}

	});

	// Countdown Timer
	var $countDown = $('.countdown');
	if($countDown.length > 0) {
		$countDown.each(function(){

			var animation =  $(this).data('animation'),
					direction = $(this).data('direction'),
					circleFgWidth = $(this).data('fg-width'),
					circleBgWidth = $(this).data('bg-width'),
					circleBgColor = $(this).data('bg-color'),
					circleFgColorD = $(this).data('fg-color-days'),
					circleFgColorH = $(this).data('fg-color-hours'),
					circleFgColorM = $(this).data('fg-color-minutes'),
					circleFgColorS = $(this).data('fg-color-seconds'),
					circleDlabel = $(this).data('days-label'),
					circleHlabel = $(this).data('hours-label'),
					circleMlabel = $(this).data('minutes-label'),
					circleSlabel = $(this).data('seconds-label'),
					circleDshow = $(this).data('days-show'),
					circleHshow = $(this).data('hours-show'),
					circleMshow = $(this).data('minutes-show'),
					circleSshow = $(this).data('seconds-show');

			$(this).TimeCircles({
				animation: animation,
				direction: direction,
				fg_width: circleFgWidth,
				bg_width: circleBgWidth,
				circle_bg_color: circleBgColor,
				time: {
			    Days: {
			    	color: circleFgColorD,
			    	text: circleDlabel,
			    	show: circleDshow
			    },
			    Hours: {
			    	color: circleFgColorH,
			    	text: circleHlabel,
			    	show: circleHshow
			    },
			    Minutes: {
			    	color: circleFgColorM,
			    	text: circleMlabel,
			    	show: circleMshow
			    },
			    Seconds: {
			    	color: circleFgColorS,
			    	text: circleSlabel,
			    	show: circleSshow
			    }
				}
			});
		});
		$(window).on('resize', function(){
			$countDown.each(function(){
				$(this).TimeCircles().rebuild();
			});
		});
	}

	// Google Maps API
	var $googleMap = $('.google-map');
	if($googleMap.length > 0) {
		$googleMap.each(function(){
			var mapHeight = $(this).data('height'),
					address = $(this).data('address'),
					zoom = $(this).data('zoom'),
					controls = $(this).data('disable-controls'),
					scrollwheel = $(this).data('scrollwheel'),
					marker = $(this).data('marker'),
					markerTitle = $(this).data('marker-title'),
					styles = $(this).data('styles');
			$(this).height(mapHeight);
			$(this).gmap3({
          marker:{
            address: address,
            data: markerTitle,
            options: {
            	icon: marker
            },
            events: {
              mouseover: function(marker, event, context){
                var map = $(this).gmap3("get"),
                  	infowindow = $(this).gmap3({get:{name:"infowindow"}});
                if (infowindow){
                  infowindow.open(map, marker);
                  infowindow.setContent(context.data);
                } else {
                  $(this).gmap3({
                    infowindow:{
                      anchor:marker, 
                      options:{content: context.data}
                    }
                  });
                }
              },
              mouseout: function(){
                var infowindow = $(this).gmap3({get:{name:"infowindow"}});
                if (infowindow){
                  infowindow.close();
                }
              }
            }
          },
          map:{
            options:{
              zoom: zoom,
              disableDefaultUI: controls,
              scrollwheel: scrollwheel,
              styles: styles
            }
          }
			});
		});
	}

});/*Document Ready End*/