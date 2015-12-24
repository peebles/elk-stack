var _ = require( 'lodash' );
var winston = require( 'winston' );

var app = {};
app.config = require( '../config.json' );

app.config.resolve = function( path ) {
    var val = _.get( this, path );
    if ( ! val ) return val;
    if ( ! val.match( /^ENV:/ ) ) return val;
    var envvar = val.split(':')[1];
    var defvar = val.split(':')[2];
    var v = ( process.env[ envvar ] || defvar );
    _.set( this, path, v );
    return v;
}

app.config.resolve( 'smtp.from' );
app.config.resolve( 'smtp.auth.user' );
app.config.resolve( 'smtp.auth.pass' );
app.config.resolve( 'smtp.options.host' );
app.config.resolve( 'smtp.options.port' );
app.config.resolve( 'smtp.options.authMethod' );

app.log = new (winston.Logger)({
    transports: [
        new (winston.transports.Console)({ 
            colorize: true, 
            level: app.config.logger.level
        }),
        new (winston.transports.File)({ 
            json: false, 
            level: app.config.logger.level,
            filename: app.config.logger.filename
        }),
    ],
    exceptionHandlers: [
        new (winston.transports.Console)({ 
            colorize: true, 
            level: app.config.logger.level,
        }),
        new (winston.transports.File)({ 
            json: false, 
            level: app.config.logger.level,
            filename: app.config.logger.filename
        }),
    ],
});

var email = require( '../email' )( app, app.config.smtp );

email.send({
    to: 'aqpeeb@gmail.com',
    from: app.config.smtp.from,
    subject: 'Test Email',
    text: 'This is a test',
    html: '<pre>This is a test</pre>'
}, function( err ) {
    if ( err ) console.log( err );
    process.exit(0);
});
