$(document).ready(function () {
  // Diccionario de traducciones - Edita esto fácilmente
  const lang = {
    male: "VARÓN",
    female: "MUJER",
    bike: "MOTO",
    truck: "CAMIÓN",
    car: "COCHE"
  };

  window.addEventListener('message', function (event) {
    const data = event.data;

    if (data.action == 'open') {
      const type = data.type;
      const userData = data.array['user'][0];
      const licenseData = data.array['licenses'];
      const fullName = `${userData.firstname} ${userData.lastname}`;

      // Reset de licencias para que no se dupliquen al abrir/cerrar
      $('#licenses').empty();

      if (type == 'driver' || type == null) {
        $('img').show();
        $('#id-card').css('background', `url(assets/images/${type == 'driver' ? 'license' : 'idcard'}.png)`);
        $('#name').css('color', '#282828').text(fullName);

        // Traducción de Sexo e Imagen
        const isMale = userData.sex.toLowerCase() == 'm';
        $('img').attr('src', `assets/images/${isMale ? 'male' : 'female'}.png`);
        $('#sex').text(isMale ? lang.male : lang.female);

        $('#dob').text(userData.dateofbirth);
        $('#height').text(userData.height);
        $('#signature').text(fullName);

        // Lógica de Licencias mejorada
        if (type == 'driver' && licenseData) {
          licenseData.forEach(function (license) {
            let label = "";
            if (license.type == 'drive_bike') label = lang.bike;
            else if (license.type == 'drive_truck') label = lang.truck;
            else if (license.type == 'drive') label = lang.car;

            if (label) {
              $('#licenses').append(`<p class="license-item">${label}</p>`);
            }
          });
        }

      } else if (type == 'weapon') {
        $('img').hide();
        $('#name').css('color', '#d9d9d9').text(fullName);
        $('#dob').text(userData.dateofbirth);
        $('#signature').text(fullName);
        $('#id-card').css('background', 'url(assets/images/firearm.png)');
        // Limpiamos campos que no usa el carnet de armas
        $('#sex, #height').text('');
      }

      $('#id-card').fadeIn(500); // Un efecto de entrada más suave

    } else if (data.action == 'close') {
      $('#id-card').fadeOut(300, function () {
        // Limpieza total al terminar la animación
        $('#name, #dob, #height, #signature, #sex').text('');
        $('#licenses').empty();
      });
    }
  });
});