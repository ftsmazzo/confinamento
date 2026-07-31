/**
 *  @name Date (dd/mm/YYYY hh:ii[:ss])
 *  @summary Sort date / time in the format `dd/mm/YYYY hh:ii[:ss]`
 *  Seconds are optional
 */

 jQuery.extend( jQuery.fn.dataTableExt.oSort, {

    "datetime-html-pre": function ( a ) {
        var x;

        if ( $.trim(a) !== '' ) {


            var all = $.trim(a).split('<small>');
            var date = all[0];

            var frDatea2 = date.split('/');


            var time = all[1].substr(0,5);
            var frTimea = time.split(':');

            if (frTimea[2]) x = (frDatea2[2] + frDatea2[1] + frDatea2[0] + frTimea[0] + frTimea[1] + frTimea[2]) * 1;
            else            x = (frDatea2[2] + frDatea2[1] + frDatea2[0] + frTimea[0] + frTimea[1]) * 1;
        }
        else {
            x = Infinity;
        }

        return x;
    },

    "datetime-html-asc": function ( a, b ) {
        return a - b;
    },

    "datetime-html-desc": function ( a, b ) {
        return b - a;
    }
} );