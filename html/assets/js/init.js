(function () {
  const idCard = document.getElementById('id-card');
  const portrait = document.getElementById('portrait');
  const cardTitle = document.getElementById('card-title');
  const name = document.getElementById('name');
  const dob = document.getElementById('dob');
  const sex = document.getElementById('sex');
  const height = document.getElementById('height');
  const signature = document.getElementById('signature');
  const licenses = document.getElementById('licenses');

  function getUser(payload) {
    if (!payload || !payload.user) return {};
    return Array.isArray(payload.user) ? (payload.user[0] || {}) : payload.user;
  }

  function getLicenses(payload) {
    if (!payload || !payload.licenses) return [];
    return Array.isArray(payload.licenses) ? payload.licenses : Object.values(payload.licenses);
  }

  function getSexLabel(rawSex, sexLabels) {
    if (rawSex === undefined || rawSex === null) return '';

    const key = String(rawSex).toLowerCase();
    if (sexLabels && sexLabels[key]) return sexLabels[key];

    if (key === 'm') return 'male';
    if (key === 'f') return 'female';

    return key;
  }

  function getDefaultPortrait(rawSex) {
    const sexValue = String(rawSex || '').toLowerCase();
    return sexValue === 'f' || sexValue === 'female' || sexValue === '1'
      ? 'assets/images/female.png'
      : 'assets/images/male.png';
  }

  function clearCard() {
    cardTitle.textContent = '';
    name.textContent = '';
    dob.textContent = '';
    sex.textContent = '';
    height.textContent = '';
    signature.textContent = '';
    licenses.innerHTML = '';
    portrait.src = 'assets/images/male.png';
    portrait.style.display = 'block';
    idCard.className = '';
    idCard.style.display = 'none';
  }

  function addLicense(label) {
    const item = document.createElement('p');
    item.textContent = label;
    licenses.appendChild(item);
  }

  window.addEventListener('message', function (event) {
    const data = event.data || {};

    if (data.action === 'close') {
      clearCard();
      return;
    }

    if (data.action !== 'open') return;

    const payload = data.array || {};
    const userData = getUser(payload);
    const licenseData = getLicenses(payload);
    const card = payload.card || {};
    const fullName = `${userData.firstname || ''} ${userData.lastname || ''}`.trim();
    const showPhoto = card.showPhoto !== false;
    const showHeight = card.showHeight !== false;
    const showLicenses = card.showLicenses === true;

    idCard.className = card.type ? `card-${card.type}` : '';
    idCard.style.background = `url(${card.background || 'assets/images/idcard.png'})`;
    cardTitle.textContent = card.label || '';
    name.textContent = fullName;
    dob.textContent = userData.dateofbirth || '';
    sex.textContent = getSexLabel(userData.sex, payload.sexLabels);
    height.textContent = showHeight && userData.height ? String(userData.height) : '';
    signature.textContent = fullName;
    licenses.innerHTML = '';

    if (showPhoto) {
      portrait.src = payload.mugshot || getDefaultPortrait(userData.sex);
      portrait.style.display = 'block';
    } else {
      portrait.style.display = 'none';
    }

    if (showLicenses) {
      licenseData.forEach(function (license) {
        addLicense(license.label || license.type || '');
      });
    }

    idCard.style.display = 'block';
  });
})();
