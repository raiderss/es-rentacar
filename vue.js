
const app = new Vue({
  el: '#app',
  data: {
    select:0,
    ui:false,
    vehicles:[],
    position:{vehicle:"", location:""},
    price:"",
    speed:"",
    fuel:"",
    traction:"",
    acceleration:""
   },
   methods: {
    Q:function(data){
      setTimeout(function(){
        $.post(`https://${GetParentResourceName()}/Vehicle`, JSON.stringify({vehicle:data}), function(data){
          app.speed = Math.floor(data.speed),
          app.fuel = Math.floor(data.fuel),
          app.traction = Math.floor(data.traction),
          app.acceleration = Math.floor(data.acceleration)
        })
      }, 100);
      this.select = data.model,
      this.price = data.price,
      $.post(`https://${GetParentResourceName()}/Delete`, JSON.stringify({}));
    },
    Buy(){
      $.post(`https://${GetParentResourceName()}/Buy`, JSON.stringify({model:this.select, price:this.price}));
      setTimeout(function(){
        $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
        app.ui = false;
      }, 100);
    },
    rent:function(data){
      this.vehicles = data;
    },
    menu:function(data){
      this.ui = data;
  },
}
  })
  
  window.addEventListener('message', function (event) {
    var item = event.data;
    if (item.type === "ui") {
      app.menu(true),app.rent(item.rent)
    }
  })

  document.onkeyup = function (data) {
    if (data.which == 27) {
      app.menu(false);
      $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
    }
    $(document).on('keydown', function(bind) {
      switch(bind.which) {
        case 68: // D
            $.post(`https://${GetParentResourceName()}/rotateright`);
            break;
        case 39: // ArrowRight
            $.post(`https://${GetParentResourceName()}/rotateright`);
            break;
        case 65: // A
            $.post(`https://${GetParentResourceName()}/rotateleft`);
            break;
        case 37: // ArrowLeft
            $.post(`https://${GetParentResourceName()}/rotateleft`);
            break;
      }
    });
  };

  