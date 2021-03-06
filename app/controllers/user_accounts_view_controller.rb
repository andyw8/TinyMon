class UserAccountsViewController < UITableViewController
  include Refreshable
  include RootController
  
  attr_accessor :user_accounts
  
  def init
    @user_accounts = []
    super
  end
  
  def viewDidLoad
    self.title = I18n.t("user_accounts_controller.title")
    
    load_data
    
    on_refresh do
      load_data
    end
    
    super
  end
  
  def viewWillAppear(animated)
    super
    tableView.reloadData
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    @user_accounts.size
  end
  
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    fresh_cell.tap do |cell|
      cell.user_account = user_accounts[indexPath.row]
    end
  end
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    navigationController.pushViewController(UserViewController.alloc.initWithUser(user_accounts[indexPath.row].user), animated:true)
  end
  
  def load_data
    TinyMon.when_reachable do
      SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
      UserAccount.find_all(:account_id => Account.current.id) do |results, response|
        SVProgressHUD.dismiss
        if response.ok? && results
          @user_accounts = results
        else
          TinyMon.offline_alert
        end
        tableView.reloadData
        end_refreshing
      end
    end
  end

private
  def fresh_cell
    tableView.dequeueReusableCellWithIdentifier('Cell') ||
    UserTableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:'Cell').tap do |cell|
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    end
  end
end
