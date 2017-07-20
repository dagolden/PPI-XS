#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* Big enough for then length of uint64_t in ASCII. */
#define UINT64_STR_MAX 20

/* Pointer value to ASCII. */
char *
ptoa(char *buf, PTRV p)
{
    char *c = buf + UINT64_STR_MAX + 1;

    do {
        *--c = '0' + (p % 10);
        p /= 10;
    } while (p);

    return c;
}

MODULE = PPI::XS	PACKAGE = PPI::XS

PROTOTYPES: DISABLE

SV *
_PPI_Element__significant (self)
    SV *    self
PPCODE:
{
    XSRETURN_YES;
}

SV *
_PPI_Token_Comment__significant (self)
    SV *    self
PPCODE:
{
    XSRETURN_NO;
}

SV *
_PPI_Token_Whitespace__significant (self)
    SV *    self
PPCODE:
{
    XSRETURN_NO;
}

SV *
_PPI_Token_End__significant (self)
    SV *    self
PPCODE:
{
    XSRETURN_NO;
}

SV *
_PPI_Element__next_sibling (self)
    SV *    self
PPCODE:
{
    PTRV key = (PTRV)SvRV(self);

    char key_buf[UINT64_STR_MAX];

    char *key_str = ptoa(key_buf, key);

    HV *_PARENT = get_hv("PPI::Element::_PARENT", 0);

    I32 key_str_len = UINT64_STR_MAX - (key_str - key_buf) + 1;

    SV **parent_ptr = hv_fetch(_PARENT, key_str, key_str_len, 0);

    if (parent_ptr) {
        HV *parent   = (HV *)SvRV(*parent_ptr);
        AV *children = (AV *)SvRV(*hv_fetchs(parent, "children", 0));

        SV **ary = AvARRAY(children);
        SSize_t top = av_tindex(children);

        for (Size_t i = 0; i < top; i++)
            if (key == (PTRV)SvRV(ary[i])) {
                ST(0) = ary[i + 1];
                XSRETURN(1);
            }
    }

    XSRETURN_NO;
}
