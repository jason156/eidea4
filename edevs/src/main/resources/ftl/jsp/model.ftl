<%--
  Created by ${user}.
  Date: ${datetime}
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="/inc/taglib.jsp" %>
<html>
<head>
    <title><%--${modelName}--%><eidea:label key="${model?uncap_first}.title"/></title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <%@include file="/inc/inc_ang_js_css.jsp" %>
</head>
<body>
<div ng-app='myApp' ng-view class="content"></div>
<jsp:include page="/common/searchPage">
    <jsp:param name="uri" value="${r'${uri}'}"/>
</jsp:include>
</body>
<script type="text/javascript">
    var app = angular.module('myApp', ['ngRoute', 'ui.bootstrap', 'jcs-autoValidate'])
            .config(['$routeProvider', function ($routeProvider) {
                $routeProvider
                        .when('/list', {templateUrl: '<c:url value="/${module}/${model?uncap_first}/list.tpl.jsp"/>'})
                        .when('/edit', {templateUrl: '<c:url value="/${module}/${model?uncap_first}/edit.tpl.jsp"/>'})
                        .otherwise({redirectTo: '/list'});
            }]);
    app.controller('listCtrl', function ($scope, $http) {
        $scope.allList = [];
        $scope.modelList = [];
        $scope.delFlag = false;
        $scope.canDel=PrivilegeService.hasPrivilege('delete');
        $scope.canAdd=PrivilegeService.hasPrivilege('add');
        $http.get("<c:url value="/${module}/${model?uncap_first}/list"/>")
                .success(function (response) {
                    if (response.success) {
                        $scope.updateList(response.data);
                    }
                    else {
                        bootbox.alert(response.message);
                    }

                });
        $scope.updateList = function (data) {
            $scope.allList = data;
            $scope.bigTotalItems = $scope.allList.length;
            $scope.modelList.length = 0;
            $scope.pageChanged();
        };
        $scope.pageChanged = function (delF) {
            var bgn = ($scope.bigCurrentPage - 1) * $scope.itemsPerPage;
            var end = bgn + $scope.itemsPerPage;
            $scope.modelList.length = 0;
            if (delF == null) {
                delF = false;
            }
            for (var i = bgn; i < end && i < $scope.allList.length; i++) {
                var item = $scope.allList[i];
                item.delFlag = delF;
                $scope.modelList.push(item);

            }
        }
        $scope.canDelete = function () {
            for (var i = 0; i < $scope.modelList.length; i++) {
                if ($scope.modelList[i].delFlag) {
                    return true;
                }
            }
            return false;
        }
        $scope.selectAll = function () {
            $scope.pageChanged($scope.delFlag);
        }
        $scope.deleteRecord = function () {

            bootbox.confirm({
                message: "<eidea:message key="common.warn.confirm.deletion"/>",
                buttons: {
                    confirm: {
                        label: '<eidea:label key="common.button.yes"/>',
                        className: 'btn-success'
                    },
                    cancel: {
                        label: '<eidea:label key="common.button.no"/>',
                        className: 'btn-danger'
                    }
                },
                callback: function (result) {
                    if (result) {
                        var ${pkProp}s = [];
                        for (var i = 0; i < $scope.modelList.length; i++) {
                            if ($scope.modelList[i].delFlag) {
                                ids.push($scope.modelList[i].id);
                            }
                        }
                        $http.post("<c:url value="/${module}/${model?uncap_first}/deletes"/>", ${pkProp}).success(function (data) {
                            if (data.success) {
                                bootbox.alert("<eidea:message key="common.warn.deleted.success"/>");
                                $scope.updateList(data.data);
                            }
                            else {
                                bootbox.alert(data.message);
                            }

                        });
                    }
                }
            });
        };
        //可现实分页item数量
        $scope.maxSize =${r'${pagingSettingResult.pagingButtonSize}'};
        //每页现实记录数
        $scope.itemsPerPage =${r'${pagingSettingResult.perPageSize}'};
        //当前页
        $scope.bigCurrentPage = 1;
        //记录数
        $scope.bigTotalItems = 0;
    });
    app.controller('editCtrl', function ($scope, $http, $routeParams) {
        $scope.message = '';
        $scope.${model?uncap_first}Po = {};
        $scope.canAdd=PrivilegeService.hasPrivilege('add');
        var url = "<c:url value="/${module}/${model?uncap_first}/create"/>";
        if ($routeParams.${pkProp} != null) {
            url = "<c:url value="/${module}/${model?uncap_first}/get"/>" + "?${pkProp}=" + $routeParams.${pkProp};
        }
        $http.get(url)
                .success(function (response) {
                    if (response.success) {
                        $scope.${model?uncap_first}Po = response.data;
                        $scope.canSave=(PrivilegeService.hasPrivilege('add')&&$scope.${model?uncap_first}Po.${pkProp}==null)||PrivilegeService.hasPrivilege('update');
                    }
                    else {
                        bootbox.alert(response.message);
                    }
                }).error(function (response) {
            bootbox.alert(response);
        });
        $scope.save = function () {
            if ($scope.editForm.$valid) {
                var postUrl = '<c:url value="/${module}/${model?uncap_first}/saveForUpdated"/>';
                if ($scope.${model?uncap_first}Po.${pkProp} == null) {
                    postUrl = '<c:url value="/${module}/${model?uncap_first}/saveForCreated"/>';
                }
                $http.post(postUrl, $scope.${model?uncap_first}Po).success(function (data) {
                    if (data.success) {
                        $scope.message = "<eidea:label key="base.save.success"/>";
                        $scope.${model?uncap_first}Po = data.data;
                    }
                    else {
                        $scope.message = data.message;
                        $scope.errors=data.data;
                    }
                }).error(function (data, status, headers, config) {
                    alert(JSON.stringify(data));
                });
            }
        }
        $scope.create = function () {
            $scope.message = "";
            $scope.${model?uncap_first}Po = {};
            var url = "<c:url value="/${module}/${model?uncap_first}/create"/>";
            $http.get(url)
                    .success(function (response) {
                        if (response.success) {
                            $scope.${model?uncap_first}Po = response.data;
                            $scope.canSave=(PrivilegeService.hasPrivilege('add')&&$scope.${model?uncap_first}Po.${pkProp}==null)||PrivilegeService.hasPrivilege('update');
                        }
                        else {
                            bootbox.alert(response.message);
                        }
                    }).error(function (response) {
                bootbox.alert(response);
            });
        }

    });
    app.run([
        'bootstrap3ElementModifier',
        function (bootstrap3ElementModifier) {
            bootstrap3ElementModifier.enableValidationStateIcons(true);
        }]);
</script>
</html>
