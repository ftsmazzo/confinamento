jQuery.extend( jQuery.fn.dataTableExt.oSort, {
	"currency-br-pre": function ( a ) {
		a = (a == "-") ? 0 : a.replace( /[^\d]/g, "" ).replace( /\./g, "" ).replace( /,/, "." );
		return parseFloat( a );
	},

	"currency-br-asc": function ( a, b ) {
	    var x = (a == "-") ? 0 : a.replace( /[^\d]/g, "" ).replace( /\./g, "" ).replace( /,/, "." );
	    var y = (b == "-") ? 0 : b.replace( /[^\d]/g, "" ).replace( /\./g, "" ).replace( /,/, "." );
	    x = parseFloat( x );
	    y = parseFloat( y );
	    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
	},

	"currency-br-desc": function ( a, b ) {
	    var x = (a == "-") ? 0 : a.replace( /[^\d]/g, "" ).replace( /\./g, "" ).replace( /,/, "." );
	    var y = (b == "-") ? 0 : b.replace( /[^\d]/g, "" ).replace( /\./g, "" ).replace( /,/, "." );
	    x = parseFloat( x );
	    y = parseFloat( y );
	    return ((x < y) ? 1 : ((x > y) ?  -1 : 0));
	}
} );
