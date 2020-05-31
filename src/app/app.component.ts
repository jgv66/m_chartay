import { Component, OnInit } from '@angular/core';
import { Platform, ToastController, AlertController } from '@ionic/angular';
import { SplashScreen } from '@ionic-native/splash-screen/ngx';
import { StatusBar } from '@ionic-native/status-bar/ngx';
// import { SwUpdate } from '@angular/service-worker';
// import { Plugins } from '@capacitor/core';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss']
})
export class AppComponent implements OnInit {

  deferredPrompt;
  showInstaller = false;

  constructor( private platform: Platform,
               private toastCtrl: ToastController,
               // private swUpdate: SwUpdate,
               private alertCtrl: AlertController,
               private splashScreen: SplashScreen,
               private statusBar: StatusBar ) {
    this.initializeApp();
  }

  ngOnInit() {
    // ? se habra instalado ?
    window.addEventListener('appinstalled', (evt) => {
      console.log('a2hs installed');
    });
    // como se cargó?
    window.addEventListener('load', () => {
      // tslint:disable-next-line: no-string-literal
      if (window.navigator['standalone']) {
        console.log('Launched: Installed (iOS)');
      } else if (matchMedia('(display-mode: standalone)').matches) {
        console.log('Launched: Installed');
      } else {
        console.log('Launched: Browser Tab');
      }
    });
    // estará actualizada?
    /*
    if ( this.swUpdate.isEnabled ) {
      this.swUpdate.available
          .subscribe( async (event) => {
            // ----------------------------
            const alert = await this.alertCtrl.create({
              // header: 'Actualización!',
              message: 'Existe una nueva versión de Mandala, lista para descargar. (' + event.available + ')',
              buttons: [
                {
                  text: 'Cancelar',
                  role: 'cancel',
                  handler: () => {}
                }, {
                  text: 'Actualizar !',
                  handler: () => { window.location.reload(); }
                }
              ]
            });
            await alert.present();
            // ----------------------------
          });
    }
    */
  }

  initializeApp() {
    this.platform.ready().then(() => {
      // this.statusBar.styleDefault();
      // this.splashScreen.hide();
      // this.revisarDarkTheme();
      this.checkForPwaToast();
    });
  }

  async checkForPwaToast() {
    const isIos = () => {
      const userAgent = window.navigator.userAgent.toLowerCase();
      // console.log(userAgent);
      return /iphone|ipad|ipod/.test(userAgent);
    };
    const isAndroid = () => {
      const userAgent = window.navigator.userAgent.toLowerCase();
      // console.log(userAgent);
      return /android/.test(userAgent);
    };
    // tslint:disable-next-line: no-string-literal
    const isInStandaloneMode = () => ('standalone' in window.navigator) && (window.navigator['standalone']);

    // console.log(isIos(), isAndroid(), !isInStandaloneMode() );

    if (isIos() && !isInStandaloneMode()) {
      const toast = await this.toastCtrl.create({
        message: 'Si desea instalar seleccione: Compartir -> Add to Home Screen',
        position: 'bottom',
        duration: 10000,
        color: 'mango',
        translucent: true,
        mode: 'md',
        // closeButtonText: 'Ok',
        // showCloseButton: true,
        cssClass: 'instalar'
      });
      toast.present();
    } /* else if (isAndroid() && !isInStandaloneMode()) {
      window.addEventListener('beforeinstallprompt', (event) => {
        // Prevent Chrome <= 67 from automatically showing the prompt
        event.preventDefault();
        // Stash the event so it can be triggered later.
        let installPromptEvent = event;
        // Update the install UI to notify the user app can be installed
        // document.querySelector('#install-button').disabled = false;
        this.deferredPrompt = e;
        this.showInstaller = true;
        window.showInstallPromotion();
      });
      // button click event to show the promt
      window.addEventListener('appinstalled', (event) => {
       console.log('installed');
      });
      if (window.matchMedia('(display-mode: standalone)').matches) {
        console.log('display-mode is standalone');
      }
    }*/
  }

  // async revisarDarkTheme() {
  //   const { value } = await Plugins.Storage.get({ key: 'darkmode' });
  //   // const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
  //   console.log( value, (value === 'true') );
  //   // if (prefersDark.matches) {
  //   if ( value === 'true' ) {
  //     document.body.classList.toggle( 'dark' );
  //   }
  // }

}
