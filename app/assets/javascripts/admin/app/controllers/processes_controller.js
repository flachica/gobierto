this.GobiertoAdmin.ProcessesController = (function() {
  function ProcessesController() {}

  ProcessesController.prototype.form = function() {
    addSetProcessDurationBehavior();
  };

  function addSetProcessDurationBehavior() {
    var $durationCheckbox = $('#process_has_duration');
    $durationCheckbox.click(function(){
      var $datepickersWrapper = $("[data-behavior='process_datepickers']");
      $datepickersWrapper.toggle('slow');
    });
  };

  return ProcessesController;
})();

this.GobiertoAdmin.processes_controller = new GobiertoAdmin.ProcessesController;
