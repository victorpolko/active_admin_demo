ActiveAdmin.register User do
  menu priority: 1, parent: 'Пользователи'#, label: 'Пользователи'
  permit_params :name, :email, :state, :legs, :arms, :iq, :picture
  actions :all#, except: :destroy
  config.batch_actions = false
  config.clear_action_items!


  # SCOPES, all defined in model (models/user.rb)
  scope 'Bсе',     :all
  scope 'Cвежие',  :fresh
  scope 'Мёртвыe', :dead


  # VIEWS
  # index
  index do
    column :name
    column :email
    column :iq do |user|
      user.head.iq
    end

    column :legs
    column :arms

    # Here Rails will get only translation from corresponding field (locale.yml):
    # column t('activerecord.attributes.user.state') do |user|  => would do the same
    column :state      do |user|
      user.state.zero? ? 'Зарегистрирован' : 'Умер'
    end

    column :created_at do |user|
      Russian::strftime(user.created_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
    end

    column :updated_at do |user|
      Russian::strftime(user.updated_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
    end

    column 'Действия'  do |user|
      out = link_to('Подробней',   admin_user_path(user)) + " " +
            link_to('Выписать',    admin_user_path(user), method: :delete) + " "
      user.state.zero? ? out << link_to('Усыпить', send_out_admin_user_path(user)) : out << link_to('Воскресить', resurrect_admin_user_path(user))
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
        panel 'Контакты' do
          attributes_table_for user do
            row :name

            row :state do
              ol do
                h5 user.state.zero? ? 'Зарегистрирован' : 'Умер'
                li do
                  h4 "Количество рук: #{user.arms}"
                end
                li do
                  h4 "Количество ног: #{user.legs}"
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
                user.state.zero? ? 'Зарегистрирован' : 'Умер'
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
          column 'Имя', :name
          column        :email
          column 'IQ' do |user|
            user.head.iq
          end

          column 'Ноги', :legs
          column 'Руки', :arms

          column 'Состояние' do |user|
            user.state.zero? ? 'Зарегистрирован' : 'Умер'
          end

          column 'Дата регистрации' do |user|
            Russian::strftime(user.created_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
          end

          column 'Обновлён'         do |user|
            Russian::strftime(user.updated_at.in_time_zone('Moscow'), "%d %B %Y, %H:%M")
          end

          column 'Действия'         do |user|
            out = link_to('Выписать',    admin_user_path(user), method: :delete) + " "
            user.state.zero? ? out << link_to('Усыпить', send_out_admin_user_path(user)) : out << link_to('Воскресить', resurrect_admin_user_path(user))
          end
        end
      end
    end
  end


  # ACTIONS
  member_action :send_out do
    User.find(params[:id]).update(state: 1)
    redirect_to admin_users_path
  end

  member_action :resurrect do
    User.find(params[:id]).update(state: 0)
    redirect_to admin_users_path
  end

  collection_action :delete_all, method: :delete do
    User.destroy_all
    redirect_to action: :index
  end


  # ACTION ITEMS
  action_item only: :index do
    link_to 'Вписать нового', new_admin_user_path
  end

  action_item only: :index do
    link_to 'Амнистия!', delete_all_admin_users_path, method: :delete, confirm: 'Точно-точно?' if User.any?
  end

  action_item only: :show do
    link_to 'Редактировать', edit_admin_user_path(user)
  end

  action_item only: :show do
    user.state.zero? ? link_to('Усыпить', send_out_admin_user_path(user)) : link_to('Воскресить', resurrect_admin_user_path(user))
  end

  action_item only: :show do
    link_to 'Выписать', admin_user_path(user), method: :delete
  end


  # CONTROLLER
  controller do
    # Можно проще переопределить название конкретной страницы
    # def new
    #   @page_title = 'Создание пользователя'
    #   super
    # end

    def destroy
      super
      flash[:notice] = 'Пользователь был успешно выписан и поехал домой.'
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
