<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>서울 구별 지도 표시</title>
<link rel="stylesheet" type="text/css" href="/css/w3.css">
<link rel="stylesheet" type="text/css" href="/css/user.css">

<style>
	#map {
	    width: 1200px;
	    height: 700px;
	    margin: 0 auto; /* 가운데 정렬 */
        border: 1px solid #ddd; /* 맵 테두리 */
	}


	.area {
    position: absolute;
    background: #fff;
    border: 1px solid #888;
    border-radius: 3px;
    font-size: 12px;
    top: -5px;
    left: 15px;
    padding:2px;
	}
	
	.info {
	    font-size: 12px;
	    padding: 5px;
	}
	.info .title {
	    font-weight: bold;
	}
</style>
</head>
<body class="w3-aqua">
<div class="w3-center">
	<h1 class="w3-pink" style="margin: 0; position: fixed; top: 0;line-height:80px;height:80px; width: 100%;">지이이이잉이잉도도도돋돋도도</h1>
	<div class="w3-text-black" id="map" style=" margin-top: 100px; margin-bottom: 100px;"></div>
	<h1 class="w3-pink w3-text-pale-red" style="margin: 0; position: fixed; bottom: 0;line-height:80px;height:80px; width: 100%;">
	"국토교통부_행정구역시군구_경계" 데이터 사용</h1>
</div>
<script type="text/javascript" src="/js/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=35379a3118419781fdc5be592d7fe272"></script>
<script>
    var mapContainer = document.getElementById('map');
    var mapOption = {
        center: new kakao.maps.LatLng(37.566535, 126.9779692),
        minLevel: 8,
        maxLevel: 10,
        level: 9
    };
    var map = new kakao.maps.Map(mapContainer, mapOption);
    var customOverlay = new kakao.maps.CustomOverlay({});
    var infowindow = new kakao.maps.InfoWindow({ removable: true });

    var jsonFiles = [
        {
            url: 'https://raw.githubusercontent.com/SeoJun98/data/main/LARD_ADM_SECT_SGG_%EC%9D%B8%EC%B2%9C.json',
            fillColor: '#FF5733' // 인천 지역의 색상
        },
        {
            url: 'https://raw.githubusercontent.com/SeoJun98/data/main/LARD_ADM_SECT_SGG_%EC%84%9C%EC%9A%B8.json',
            fillColor: '#33FF57' // 서울 지역의 색상
        },
        {
            url: 'https://raw.githubusercontent.com/SeoJun98/data/main/LARD_ADM_SECT_SGG_%EA%B2%BD%EA%B8%B0.json',
            fillColor: '#5733FF' // 경기 지역의 색상
        }
    ];

    for (var i = 0; i < jsonFiles.length; i++) {
        $.getJSON(jsonFiles[i].url, (function(fillColor) {
            return function(data) {
                var features = data.features;
                for (var j = 0; j < features.length; j++) {
                    var geometry = features[j].geometry;
                    var type = geometry.type;
                    var coordinates = geometry.coordinates;
                    var name = features[j].properties.SGG_NM;

                    if (type === "Polygon") {
                        var path = coordinates[0].map(function(coord) {
                            return new kakao.maps.LatLng(coord[1], coord[0]);
                        });

                        var polygon = new kakao.maps.Polygon({
                            map: map,
                            path: path,
                            strokeWeight: 2,
                            strokeColor: '#004c80',
                            strokeOpacity: 0.8,
                            strokeStyle: 'solid',
                            fillColor: fillColor,
                            fillOpacity: 0.7
                        });

                        // 마우스 오버 이벤트
                        kakao.maps.event.addListener(polygon, 'mouseover', (function(polygon, name) {
                            return function(mouseEvent) {
                                polygon.setOptions({ fillColor: '#09f' });
                                customOverlay.setContent('<div class="area">' + name + '</div>'); // name 변수 사용
                                customOverlay.setPosition(mouseEvent.latLng); // mouseEvent.latLng 사용
                                customOverlay.setMap(map);
                            };
                        })(polygon, name));
                        
                        //마우스 무브 이벤트
                        kakao.maps.event.addListener(polygon, 'mousemove', (function(polygon, fillColor) {
                            return function(mouseEvent) {
                            	customOverlay.setPosition(mouseEvent.latLng); 
                            };
                        })(polygon, fillColor));
                        

                        // 마우스 아웃 이벤트
                        kakao.maps.event.addListener(polygon, 'mouseout', (function(polygon, fillColor) {
                            return function(mouseEvent) {
                                polygon.setOptions({ fillColor: fillColor });
                                customOverlay.setMap(null);
                            };
                        })(polygon, fillColor));

                        // 마우스 클릭 이벤트
                        kakao.maps.event.addListener(polygon, 'click', (function(polygon, name) {
                            return function(mouseEvent) {
                                var content = '<div class="info">' +
                                    '   <div class="title">' + name + '</div>' +
                                    '</div>';

                                infowindow.setContent(content);
                                infowindow.setPosition(mouseEvent.latLng);
                                infowindow.open(map);
                            };
                        })(polygon, name));
                    }

                    else if (type === "MultiPolygon") {
                        for (var k = 0; k < coordinates.length; k++) {
                            var path = coordinates[k][0].map(function(coord) {
                                return new kakao.maps.LatLng(coord[1], coord[0]);
                            });

                            var polygon = new kakao.maps.Polygon({
                                map: map,
                                path: path,
                                strokeWeight: 2,
                                strokeColor: '#004c80',
                                strokeOpacity: 0.8,
                                strokeStyle: 'solid',
                                fillColor: fillColor,
                                fillOpacity: 0.7
                            });

                            // 마우스 오버 이벤트
                            kakao.maps.event.addListener(polygon, 'mouseover', (function(polygon, name) {
                                return function(mouseEvent) {
                                    polygon.setOptions({ fillColor: '#09f' });
                                    customOverlay.setContent('<div class="area">' + name + '</div>'); // name 변수 사용
                                    customOverlay.setPosition(mouseEvent.latLng); // mouseEvent.latLng 사용
                                    customOverlay.setMap(map);
                                };
                            })(polygon, name));
                            
                            //마우스 무브 이벤트
                            kakao.maps.event.addListener(polygon, 'mousemove', (function(polygon, fillColor) {
                                return function(mouseEvent) {
                                	customOverlay.setPosition(mouseEvent.latLng); 
                                };
                            })(polygon, fillColor));

                            // 마우스 아웃 이벤트
                            kakao.maps.event.addListener(polygon, 'mouseout', (function(polygon, fillColor) {
                                return function(mouseEvent) {
                                    polygon.setOptions({ fillColor: fillColor });
                                    customOverlay.setMap(null);
                                };
                            })(polygon, fillColor));
                            
                            

                            // 마우스 클릭 이벤트
                            kakao.maps.event.addListener(polygon, 'click', (function(polygon, name) {
                                return function(mouseEvent) {
                                    var content = '<div class="info">' +
                                        '   <div class="title">' + name + '</div>' +
                                        '</div>';

                                    infowindow.setContent(content);
                                    infowindow.setPosition(mouseEvent.latLng);
                                    infowindow.open(map);
                                };
                            })(polygon, name));
                        }
                    }
                }
            };
        })(jsonFiles[i].fillColor));
    }
</script>

</body>
</html>