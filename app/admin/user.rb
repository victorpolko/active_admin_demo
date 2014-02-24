ActiveAdmin.register User do
  menu priority: 1, parent: 'Пользователи'#, label: 'Пользователи'
  permit_params :name, :email, :state, :legs, :arms, :iq, :picture
  actions :all#, except: [:destroy] || only: [:index, :show]
  # config.batch_actions = false
  config.clear_batch_actions!
  config.clear_action_items!


  # SCOPES, all defined in model (models/user.rb)
  scope -> { I18n.t('active_admin.all')               }, :all
  scope -> { I18n.t('activerecord.models.user.fresh') }, :fresh
  scope -> { I18n.t('activerecord.models.user.dead')  }, :dead

  # FILTERS
  filter :name#,  label: -> { I18n.t('activerecord.attributes.user.name')  }
  filter :email#, label: -> { I18n.t('activerecord.attributes.user.email') }
  filter :state, as: :select, collection: -> { [[t('active_admin.user.state.fresh'), 0], [t('active_admin.user.state.dead'), 1]] }
  filter :legs#,  label: -> { I18n.t('activerecord.attributes.user.legs') }
  filter :arms#,  label: -> { I18n.t('activerecord.attributes.user.arms') }

  # VIEWS
  # index
  index do
    selectable_column # this column is required for batch actions
    # column t('activerecord.attributes.user.name'), :name # would do the same as 'column :name' with correct translations (ru.activerecord.attributes.user.name)
    column :name
    column :email
    column :iq do |user|
      user.head.iq
    end

    column :legs
    column :arms

    # Here ActiveAdmin DSL gets only translation from corresponding field (locale.yml):
    # column t('activerecord.attributes.user.state') do |user| # -> would do the same
    column :state      do |user|
      user.state.zero? ? status_tag(t('active_admin.user.state.fresh'), :ok) : status_tag(t('active_admin.user.state.dead'), :error )
    end

    column :created_at do |user|
      Russian::strftime(user.created_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
    end

    column :updated_at do |user|
      Russian::strftime(user.updated_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
    end

    column t('active_admin.actions')  do |user|
      out = link_to(t('active_admin.user.actions.details'),   admin_user_path(user)) + " " +
            link_to(t('active_admin.user.actions.checkout'),    admin_user_path(user), method: :delete) + " "
      user.state.zero? ? out << link_to(t('active_admin.user.actions.send_out'), send_out_admin_user_path(user)) : out << link_to(t('active_admin.user.actions.resurrect'), resurrect_admin_user_path(user))
    end
  end

  # new || edit
  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :arms, as: :select, collection: 0..3, include_blank: false
      f.input :legs, as: :select, collection: 0..3, include_blank: false
      f.input :iq,   as: :number, input_html: { value: user.head ? user.head.iq : ''  }
      f.input :picture
    end

    f.actions do
      f.action :submit, label: t('active_admin.accept')
      f.action :cancel, label: t('active_admin.cancel'), wrapper_html: { class: 'cancel' }
    end
  end

  # show
  show title: :name do |user|
    div class: 'user-show' do
      div class: 'left_block' do
        panel t('active_admin.contacts') do
          attributes_table_for user do
            row :name

            row :state do
              ol do
                h5 user.state.zero? ? t('active_admin.user.state.fresh') : t('active_admin.user.state.dead')
                li do
                  # Passing variables to translation:
                  h4 t('active_admin.user.arms_count', arms: user.arms)
                end
                li do
                  h4 t('active_admin.user.legs_count', legs: user.legs)
                end
              end
            end

            row :iq do
              h6 user.head.iq
            end

            row :email

            row :created_at do
              Russian::strftime(user.created_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
            end

            row :updated_at do
              Russian::strftime(user.updated_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
            end
          end
        end
      end

      div class: 'right_block' do
        panel 'Описание' do
          para class: 'left_block' do
            "Пациент #{user.name.capitalize} обследуется в нашей клинике уже довольно давно - с сентября позапрошлого года. В течение этого времени проводились разные испытания психики больного; тесты показали, что состояние пациента меняется плавно и зависит от формы таблеток и температуры воды, которой он их запивает. А вообще, Lorem ipsum dolor sit amet, consectetur adipisicing elit. Consectetur, amet, rerum, natus, fugiat quae similique repudiandae illum maxime debitis beatae fuga tempore quibusdam adipisci expedita aut soluta ea dolorem nesciunt?Omnis, sit, hic, a, nesciunt tenetur quos distinctio id eius nemo doloribus quam natus corporis labore ipsa repellat error fugiat aliquam rem veritatis sint repudiandae debitis esse est dignissimos earum.Excepturi, soluta nulla quidem velit? Nostrum, et ratione dolor blanditiis unde quo reiciendis molestiae modi rem sapiente saepe earum recusandae animi iste inventore. Ipsa, officiis alias sunt ducimus suscipit non!Suscipit, est, necessitatibus ducimus obcaecati perspiciatis sed doloremque blanditiis dolor mollitia reiciendis aliquam numquam fuga quia repellat fugiat dolorum expedita sit harum natus modi consequatur error iste doloribus."
          end

          div class: 'pull-right' do
            image_tag user.picture.present? ? user.picture : 'glad_patient.png', size: '200x300'
          end

          div class: 'pull-right' do
            attributes_table_for user do
              row :name
              row :iq do
                user.head.iq
              end
              row :state do
                user.state.zero? ? t('active_admin.user.state.fresh') : t('active_admin.user.state.dead')
              end
              row :created_at do
                Russian::strftime(user.created_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
              end

              row :updated_at do
                Russian::strftime(user.updated_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
              end
            end
          end
          div class: 'clear'
        end
      end

      div class: 'bottom_block' do
        table_for user, class: 'index_table' do
          column t('activerecord.attributes.user.name'), :name
          column :email
          column t('activerecord.attributes.head.iq') do |user|
            user.head.iq
          end

          column t('activerecord.attributes.user.legs'), :legs
          column t('activerecord.attributes.user.arms'), :arms

          column t('activerecord.attributes.user.state') do |user|
            user.state.zero? ? t('active_admin.user.state.fresh') : t('active_admin.user.state.dead')
          end

          column t('activerecord.attributes.user.created_at') do |user|
            Russian::strftime(user.created_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
          end

          column t('activerecord.attributes.user.updated_at') do |user|
            Russian::strftime(user.updated_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
          end

          column t('active_admin.actions') do |user|
            out = link_to(t('active_admin.user.actions.checkout'), admin_user_path(user), method: :delete) + " "
            user.state.zero? ? out << link_to(t('active_admin.user.actions.send_out'), send_out_admin_user_path(user)) : out << link_to(t('active_admin.user.actions.resurrect'), resurrect_admin_user_path(user))
          end
        end
      end
    end
  end

  # SIDEBAR (optional)
  sidebar "Какой-то сайдбар" do
    ol do
      User.all.each do |user|
        li user.name + " : " + user.email + " : " + (user.state.zero? ? t('active_admin.user.state.fresh') : t('active_admin.user.state.dead'))
      end
    end
  end


  # ACTIONS
  # Actions for a single instance (id specification required)
  member_action :send_out do
    User.find(params[:id]).update(state: 1)
    redirect_to admin_users_path
  end

  member_action :resurrect do
    User.find(params[:id]).update(state: 0)
    redirect_to admin_users_path
  end

  # Actions for all instances (no id specified)
  collection_action :delete_all, method: :delete do
    User.destroy_all
    redirect_to action: :index
  end


  # ACTION ITEMS
  # Buttons on defined pages
  action_item only: :index do
    link_to t('active_admin.user.actions.add'), new_admin_user_path
  end

  action_item only: :index do
    link_to t('active_admin.user.actions.delete_all'), delete_all_admin_users_path, method: :delete, confirm: 'Точно-точно?' if User.any?
  end

  action_item only: :show do
    link_to t('active_admin.reduct'), edit_admin_user_path(user)
  end

  action_item only: :show do
    user.state.zero? ? link_to(t('active_admin.user.actions.send_out'), send_out_admin_user_path(user)) : link_to(t('active_admin.user.actions.resurrect'), resurrect_admin_user_path(user))
  end

  action_item only: :show do
    link_to t('active_admin.user.actions.checkout'), admin_user_path(user), method: :delete
  end


  # BATCH ACTIONS
  # From here...
  # batch_action :resurrect do |selection|
  #   names = []
  #   User.find(selection).each do |user|
  #     names << user.name
  #     user.update(state: 0)
  #   end
  #   flash[:notice] = t('active_admin.user.actions.resurrected', selection: names.join(', '))
  #   redirect_to action: :index
  # end

  # batch_action :send_out do |selection|
  #   names = []
  #   User.find(selection).each do |user|
  #     names << user.name
  #     user.update(state: 1)
  #   end
  #   flash[:notice] = t('active_admin.user.actions.sent_out', selection: names.join(', '))
  #   redirect_to action: :index
  # end

  # ...to here is the same as (meta):

  [
    { action: :send_out,  new_state: 1, priority: 1, message: 'sent_out'    },
    { action: :resurrect, new_state: 0, priority: 2, message: 'resurrected' }
  ].each do |ba|
    batch_action ba[:action], priority: ba[:priority], confirm: true do |selection|
      names = []
      User.find(selection).each do |user|
        names << user.name
        user.update(state: ba[:new_state])
      end
      redirect_to collection_path, notice: t("active_admin.user.actions.#{ba[:message]}", selection: names.join(', '))
    end
  end

  batch_action :checkout, priority: 3, confirm: 'Точно-точно?' do |selection|
    names = []
    User.find(selection).each do |user|
      names << user.name
      user.destroy
    end
    redirect_to collection_path, notice: t('active_admin.user.actions.destroyed', selection: names.join(', '))
  end


  # CONTROLLER
  controller do
    # Можно переопределить название конкретной страницы и таким образом:
    # def new
    #   @page_title = 'Создать пользователя'
    #   super
    # end

    def destroy
      super
      flash[:notice] = t('active_admin.user.actions.gone_home')
    end

    def create
      user = User.create(permitted_params.require(:user))
      if user.id
        Head.create(user_id: user.id, iq: params[:user][:iq])
        redirect_to action: :index
      else
        @user = user
        render :new
      end
    end

    def update
      user = User.find(params[:id])
      user.update(permitted_params.require(:user))
      user.head.update(iq: params[:user][:iq].to_i)
      redirect_to admin_user_path(user)
    end
  end
end
