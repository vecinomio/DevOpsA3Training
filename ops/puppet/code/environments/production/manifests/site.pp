node default {
}

node jenkins {
    include "role::jenkins"
}

node webserver {
    include "role::webserver"
}
