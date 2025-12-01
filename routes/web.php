<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});

$router->post('/simulate', 'MonteCarloController@simulate');

// Documentation endpoints
$router->get('/docs', 'DocumentationController@docs');
$router->get('/help', 'DocumentationController@index');
$router->get('/help/interpret', 'DocumentationController@interpretResults');
$router->get('/help/examples', 'DocumentationController@examples');
$router->get('/help/constraints', 'DocumentationController@constraints');
