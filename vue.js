const app = new Vue({
  el: '#app',
  data: {
    select: 0,
    ui: false,
    vehicles: [],
    position: { vehicle: "", location: "" },
    price: "",
    speed: "",
    fuel: "",
    traction: "",
    acceleration: ""
  },
  methods: {
    openUrl(url) {
      window.invokeNative("openUrl", url);
      window.open(url, '_blank');
    },
    Q: function (data) {
      setTimeout(() => {
        $.post(`https://${GetParentResourceName()}/Vehicle`, JSON.stringify({ vehicle: data }), (data) => {
          this.speed = Math.floor(data.speed),
          this.fuel = Math.floor(data.fuel),
          this.traction = Math.floor(data.traction),
          this.acceleration = Math.floor(data.acceleration)
        })
      }, 100);
      this.select = data.model;
      this.price = data.price;
      $.post(`https://${GetParentResourceName()}/Delete`, JSON.stringify({}));
    },
    Buy() {
      $.post(`https://${GetParentResourceName()}/Buy`, JSON.stringify({ model: this.select, price: this.price }));
      setTimeout(() => {
        $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
        this.ui = false;
      }, 100);
    },
    rent: function (data) {
      this.vehicles = data;
    },
    menu: function (data) {
      this.ui = data;
    }
  },
  mounted() {
    const hasVisited = localStorage.getItem('hasVisitedEyestore');
    if (!hasVisited) {
      this.openUrl('https://eyestore.tebex.io');
      localStorage.setItem('hasVisitedEyestore', 'true');
    }
    window.addEventListener('message', (event) => {
      const item = event.data;
      if (item.type === "ui") {
        this.menu(true);
        this.rent(item.rent);
      }
    });

    document.onkeyup = (data) => {
      if (data.which === 27) { /
        this.menu(false);
        $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
      }
    };

    $(document).on('keydown', (bind) => {
      switch (bind.which) {
        case 68: 
        case 39: 
          $.post(`https://${GetParentResourceName()}/rotateright`);
          break;
        case 65: 
        case 37: 
          $.post(`https://${GetParentResourceName()}/rotateleft`);
          break;
      }
    });
  }
});
