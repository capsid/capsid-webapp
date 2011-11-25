<div dojoType="dijit.layout.ContentPane" title="${level.capitalize()}s" id="${level}-panel">
    <div class="line">
        <div class="unit size1of2">
            <ul class="user-box-wrap">
                <g:render template="/layouts/userbox" model="['users':users[level+'s'], 'projectInstance':projectInstance]"/>
            </ul>
                <form action="${createLink(controller:'user',action:'promote',id:projectInstance.label, params:['level':level])}" method="post" dojoType="dijit.form.Form" id="${level}">
                    <input
                        dojoType="dojox.form.MultiComboBox"
                        style="width: 80%; float:left; margin:5px 0;"
                        store="userStore"
                        value=""
                        searchAttr="username"
                        name="users"
                        />
                    <button type="submit" class="unit right" dojoType="dijit.form.Button">Add</button>
                </form>
        </div>
        <div class="dialog lastUnit">
            <h3>${level.capitalize()}s</h3>
            <p>${description}</p>
        </div>
    </div>
</div>
