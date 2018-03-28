<?php

use Illuminate\Http\Request;

/*
 * Force ssl https://laracasts.com/discuss/channels/laravel/mixed-content-issue-content-must-be-served-as-https?page=2
 */
if (App::environment('production')) {
    URL::forceScheme('https');
}

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

/*Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});*/
