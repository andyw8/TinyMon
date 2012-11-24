class StepViewController < Formotion::FormableController
  attr_accessor :step
  
  def initWithStep(step, parent:parent, newRecord:new_record)
    @new_record = new_record
    @parent = parent
    self.step = step
    initWithModel(step)
    self.title = step.summary
    
    self.form.create_section(
      rows: [{
        title: "Save",
        type: :submit
      }]
    )
    
    self.form.on_submit do
      done_editing
    end

    unless new_record
      self.form.create_section(
        rows: [{
          title: "Delete",
          type: :delete
        }]
      )
    
      self.form.on_delete do
        delete
      end
    end
    
    self
  end
  
  def done_editing
    TinyMon.when_reachable do
      SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
      if @new_record
        self.step.create do |result|
          SVProgressHUD.dismiss
          if result
            @parent.steps << result
            target = self.navigationController.viewControllers[-3]
            self.navigationController.popToViewController(target, animated:true)
          else
            TinyMon.offline_alert
          end
        end
      else
        self.step.save do |result|
          SVProgressHUD.dismiss
          if result
            self.navigationController.popViewControllerAnimated(true)
          else
            TinyMon.offline_alert
          end
        end
      end
    end
  end

  def delete
    actionSheet = UIActionSheet.alloc.initWithTitle("Really delete?",
                                                             delegate:self,
                                                    cancelButtonTitle:"No",
                                               destructiveButtonTitle:"Yes, delete",
                                                    otherButtonTitles:nil)
  
    actionSheet.showInView(self.view)
  end
  
  def actionSheet(sender, clickedButtonAtIndex:index)
    if index == sender.destructiveButtonIndex
      TinyMon.when_reachable do
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
        self.step.destroy do |result|
          SVProgressHUD.dismiss
          if result
            @parent.steps.delete(self.step)
            self.navigationController.popViewControllerAnimated(true)
          else
            TinyMon.offline_alert
          end
        end
      end
    end
  end
end
