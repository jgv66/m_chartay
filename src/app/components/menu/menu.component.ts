import { Component, OnInit } from '@angular/core';
import { DatosService } from 'src/app/services/datos.service';

@Component({
  selector: 'app-menu',
  templateUrl: './menu.component.html',
  styleUrls: ['./menu.component.scss'],
})
export class MenuComponent implements OnInit {

  acciones: any = [
    { title: 'Bienvenida',          url: '/home',   icon: 'home-outline',     caso: 0 },
    { title: 'Ingresar a miPortal', url: '/login',  icon: 'keypad-outline',   caso: 1 },
    {
      title: 'Mis datos',
      children: [
        { title: 'Mi Ficha',          url: '/mificha',  icon: 'person-outline' },
        { title: 'Mis liquidaciones', url: '/misliqui', icon: 'newspaper-outline'   },
      ]
    },
    {
      title: 'Mis Solicitudes',
      children: [
        { title: 'Anticipos',     url: '/anticipo',      icon: 'cash-outline'        },
        { title: 'Certificados',  url: '/certificados',  icon: 'folder-open-outline' },
        { title: 'Vacaciones',    url: '/misvacaciones', icon: 'ice-cream-outline'   },
        { title: 'Licencias',     url: '/mislicencias',  icon: 'medkit-outline'      },
      ]
    },
    {
      title: 'Mis Cambios',
      children: [
        { title: 'De domicilio',          url: '/mecambie/domicilio', icon: 'pin-outline'         },
        { title: 'De número telefónico',  url: '/mecambie/numero',    icon: 'phone-portrait-outline'        },
        { title: 'De AFP',                url: '/mecambie/afp',       icon: 'trending-up-outline' },
        { title: 'De ISAPRE',             url: '/mecambie/isapre',    icon: 'nuclear-outline'     },
        { title: 'Clave de acceso',       url: '/cambioclave',        icon: 'key-outline'         },
        // { title: 'De Configuración',      url: '/temas',              icon: 'moon-outline'        },
      ]
    },
    // {
    //   title: 'Registro de Asistencia',
    //   children: [
    //     { title: 'Ingresar o Retirarse',  url: '/asistencia', icon: 'finger-print-outline'  },
    //     { title: 'Sígueme',               url: '/followme',   icon: 'walk-outline' },
    //   ]
    // },
    {
      title: 'Mensajería',
      children: [
        { title: 'Estado de mis solicitudes', url: '/miscom', icon: 'mail-outline'  },
      ]
    },
    { title: 'Cerrar sesión', url: '/logout', icon: 'exit-outline',  caso: 2 }
  ];

  constructor( public datos: DatosService ) { }

  ngOnInit() {}
  tengoFicha() { return ( (this.datos.ficha) ? true : false ); }

  onoff() {
    return ( this.datos.ficha ) ? false : true;
  }

}
