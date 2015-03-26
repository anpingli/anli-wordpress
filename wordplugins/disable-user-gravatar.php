<?php

/*

Plugin Name: Disable User Gravatar

Plugin URI: http://netweblogic.com/wordpress/plugins/disable-user-gravatar/

Description: Stops wordpress from automatically grabbing the users' gravatar with their registered email.

Author: NetWebLogic

Version: 2.0.3

Author URI: http://netweblogic.com/

Tags: gravatar, avatar, wordpress mu, wpmu, buddypress



Copyright (C) 2009 NetWebLogic LLC



This program is free software; you can redistribute it and/or modify

it under the terms of the GNU General Public License as published by

the Free Software Foundation; either version 3 of the License, or

(at your option) any later version.



This program is distributed in the hope that it will be useful,

but WITHOUT ANY WARRANTY; without even the implied warranty of

MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

GNU General Public License for more details.



You should have received a copy of the GNU General Public License

along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/



class DisableUserGravatar {

	

	var $email_template = "member.%USER%@mydomain.com";

	

	function DisableUserGravatar(){

		add_filter('get_avatar', array(&$this, 'wp_avatar'), 1, 5);

		add_filter( 'bp_core_fetch_avatar', array(&$this, 'bp_avatar'), 1, 3);

	}

	

	function wp_avatar( $content, $id_or_email){

		if( preg_match( "/gravatar.com/", $content ) ){

			if ( is_numeric($id_or_email) ) {

				$id = (int) $id_or_email;

				$user = get_userdata($id);

			} elseif ( is_object($id_or_email) ) {

				if ( !empty($id_or_email->user_id) ) {

					$id = (int) $id_or_email->user_id;

					$user = get_userdata($id);

				} elseif ( !empty($id_or_email->comment_author_email) ) {

					return $content; //Commenters not logged in don't need filtering

				}

			} else {

				$user = get_user_by_email($id_or_email);

			}

			if(!$user) return $content;

			$username = $user->user_login;

			$email = md5( str_replace('%USER%', $username, $this->email_template) );

			return preg_replace("/gravatar.com\/avatar\/(.+)\?/", "gravatar.com/avatar/{$email}?", $content);

		}

		return $content;		

	}

	

	function bp_avatar( $content, $params ){

		if( is_array($params) && $params['object'] == 'user' ){

			return $this->wp_avatar($content, $params['item_id']);

		}

		return $content;

	}

	

}



global $DisableUserGravatar;

$DisableUserGravatar = new DisableUserGravatar();
