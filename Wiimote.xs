#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <stdlib.h>
#include <cwiid.h>
#include "ppport.h"

typedef cwiid_wiimote_t *Linux__Input__Wiimote;
typedef struct cwiid_state *Linux__Input__Wiimote__State;

HV * _state_to_hv( struct cwiid_state *state ) {
    HV *hv_state = newHV();

    if (!hv_store( hv_state, "battery",     7,  newSVuv( state.battery  ), 0 )) croak ("failed to store battery");
    if (!hv_store( hv_state, "led",         3,  newSVuv( state.led      ), 0 )) croak ("failed to store led");
    if (!hv_store( hv_state, "report_mode", 11, newSVuv( state.rpt_mode ), 0 )) croak ("failed to store report_mode");
    if (!hv_store( hv_state, "rumble",      6,  newSVuv( state.rumble   ), 0 )) croak ("failed to store rumble");

    return hv_state;
}

MODULE = Linux::Input::Wiimote  PACKAGE = Linux::Input::Wiimote

PROTOTYPES: DISABLE

Linux::Input::Wiimote
new( packname="Linux::Input::Wiimote", ... )
    char *packname
PREINIT:
    char *addr;
    bdaddr_t bdaddr;
    cwiid_wiimote_t *wiimote = NULL;
CODE:
    if( items > 1 ) {
        addr = (char *)SvPV_nolen( ST( 1 ) );
        str2ba( addr, &bdaddr );
    }
    else {
        bdaddr = *BDADDR_ANY;
    }

    wiimote = cwiid_open( &bdaddr, 0 );

    /* Send a command so state will work properly */
    if( wiimote )
        cwiid_set_rumble( wiimote, 0 );

    RETVAL = wiimote;
OUTPUT:
    RETVAL

void
DESTROY( self )
    Linux::Input::Wiimote self
CODE:
    cwiid_close( self );

int
id( self )
    Linux::Input::Wiimote self
CODE:
    RETVAL = cwiid_get_id( self );
OUTPUT:
    RETVAL

int
set_led_state( self, state )
    Linux::Input::Wiimote self
    unsigned char state
CODE:
    RETVAL = cwiid_set_led( self, state );
OUTPUT:
    RETVAL

int
set_rumble( self, rumble )
    Linux::Input::Wiimote self
    unsigned char rumble
CODE:
    RETVAL = cwiid_set_rumble( self, rumble );
OUTPUT:
    RETVAL    

HV *
get_state_hv( self )
    Linux::Input::Wiimote self
PREINIT:
    struct cwiid_state *state;
INIT:
    Newx( state, 1, struct cwiid_state );
CODE:
    cwiid_get_state( self, state );
    RETVAL = _state_to_hv( state );
OUTPUT:
    RETVAL

Linux::Input::Wiimote::State
get_state( self )
    Linux::Input::Wiimote self;
PREINIT:
    struct cwiid_state *state;
INIT:
    Newx( state, 1, struct cwiid_state );
CODE:
    cwiid_get_state( self, state );
    RETVAL = state;
OUTPUT:
    RETVAL

MODULE = Linux::Input::Wiimote  PACKAGE = Linux::Input::Wiimote::State

int
rumble( self )
    Linux::Input::Wiimote::State self
CODE:
    RETVAL = self->rumble;
OUTPUT:
    RETVAL

int
battery( self )
    Linux::Input::Wiimote::State self
CODE:
    RETVAL = self->battery;
OUTPUT:
    RETVAL

int
report_mode( self )
    Linux::Input::Wiimote::State self
CODE:
    RETVAL = self->rpt_mode;
OUTPUT:
    RETVAL

int
led( self )
    Linux::Input::Wiimote::State self
CODE:
    RETVAL = self->led;
OUTPUT:
    RETVAL

void
DESTROY( self )
    Linux::Input::Wiimote::State self
CODE:
    Safefree( self );
