import { Component, HostListener } from '@angular/core';
import { MenuController } from '@ionic/angular';
import { Router } from '@angular/router';
import { DatosService } from '../../services/datos.service';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {

  showInstaller = false;
  deferredPrompt: any;
  showButton = false;
  showIosInstall: boolean;
  logeado = false;

  constructor(private menuCtrl: MenuController,
              private router: Router,
              public datos: DatosService ) {}

  menuToggle() {
    this.menuCtrl.toggle();
  }

  ingresar() {
    this.router.navigateByUrl('/login');
  }

  ionViewWillEnter() {
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      this.deferredPrompt = e;
      this.showInstaller = true;
    });
    // button click event to show the promt
    window.addEventListener('appinstalled', (event) => {
     console.log('installed');
    });
    if (window.matchMedia('(display-mode: standalone)').matches) {
      console.log('display-mode is standalone');
    }
  }

  @HostListener('window:beforeinstallprompt', ['$event'])
  onbeforeinstallprompt(e) {
    console.log(e);
    e.preventDefault();
    this.deferredPrompt = e;
    this.showButton = true;
  }

  addToHomeScreen() {
    // hide our user interface that shows our A2HS button
    this.showButton = false;
    // Show the prompt
    this.deferredPrompt.prompt();
    // Wait for the user to respond to the prompt
    this.deferredPrompt.userChoice
      .then((choiceResult) => {
        if (choiceResult.outcome === 'accepted') {
          console.log('User accepted the A2HS prompt');
        } else {
          console.log('User dismissed the A2HS prompt');
        }
        this.deferredPrompt = null;
      });
  }

  // Detects if device is on iOS
  isIos() {
    const userAgent = localStorage.getItem('userAgent'); // window.navigator.userAgent.toLowerCase();
    console.log('userAgent: ', userAgent);
    return /iphone|ipad|ipod/.test( userAgent );
  }
  // Detects if device is in standalone mode
  isInStandaloneMode() {
    console.log(localStorage.getItem('isInStandaloneMode'));
    return localStorage.getItem('isInStandaloneMode') === 'true';
  }

}
