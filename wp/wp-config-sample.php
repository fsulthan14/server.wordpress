<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'database_name_here' );

/** Database username */
define( 'DB_USER', 'username_here' );

/** Database password */
define( 'DB_PASSWORD', 'dbpassword_here' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

define( 'FORCE_SSL_ADMIN', true );
// in some setups HTTP_X_FORWARDED_PROTO might contain
// a comma-separated list e.g. http,https
// so check for https existence

if( strpos( $_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false )
    $_SERVER['HTTPS'] = 'on';

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
#IaC_Key
define('AUTH_KEY',         '85{BIx:H#+|%%-le:Vc,3KIAc(C@5^`YcKasFG(23?G%efGd :v~D6w7D+~(4`+G');
define('SECURE_AUTH_KEY',  'q-u)voTGEV5H]8M$e)T8^GPs|Zp!c`*|;({5Snd^O/URLrg:2n4S`Efj+/Vs-l(i');
define('LOGGED_IN_KEY',    'cySzf_=?&+|h0M--*^%W|2SFrPjCB+c[(D~,NCfLW4juG*OYqiLt?du+9<CnQ.v_');
define('NONCE_KEY',        'o|p3o9=8ZST>DJ-r~8M,Nf1Z0#:az|nTYS)b lV)x:gdp+^sP:S55@-Nj8-Isr$<');
define('AUTH_SALT',        '7] 2/=@V!2?`;?Fu2mTp/F|U}|D]C3VZ.aZs[ |3bSu%Pa3|N=n^P~[cP^!B[aeA');
define('SECURE_AUTH_SALT', '6z~0]|8k}ZYds-cZ&iCGlNStE8G1dz-U^j@MU:$GYasg4g:|t%{~ZqFc-fK,V0C1');
define('LOGGED_IN_SALT',   'Hrt2n9+c0^6B~%|/c)4[0sd6|]j.g?`ua?;Y.M1<E1x{lkI(*l/lhXA[nBo_ZEDZ');
define('NONCE_SALT',       ';<wZCe#U)0a:0-T7^XpfGpJ8ez@!nxV.&Kd<!ihy1fn$;jHtXMWO=&ZP|Q/W^T`t');
#Iac_End
/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */
##MULTISITE_CONFIG
define( 'MULTISITE', true );
define( 'SUBDOMAIN_INSTALL', true );
define( 'DOMAIN_CURRENT_SITE', 'ohginiye.com' );
define( 'PATH_CURRENT_SITE', '/' );
define( 'SITE_ID_CURRENT_SITE', 1 );
define( 'BLOG_ID_CURRENT_SITE', 1 );

/* That's all, stop editing! Happy publishing. */
define( 'WP_ALLOW_MULTISITE', true );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

